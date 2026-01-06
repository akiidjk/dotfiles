#!/bin/bash
# ~/.config/quickshell/lib/weather.sh

# Cache Configuration
CACHE_FILE="$HOME/.config/quickshell/.cache/ags-weather.json"
CACHE_DURATION=1800  # 30 minutes (1800 seconds)

# Create cache dir if it doesn't exist
mkdir -p "$(dirname "$CACHE_FILE")"

# Function to map OpenWeatherMap condition ID to icon
get_icon() {
    local id=$1

    # Day/Night Check (Approximate: Night is before 6AM or after 6PM)
    local current_hour=$(date +%H)
    local is_night=0
    if [ "$current_hour" -lt 6 ] || [ "$current_hour" -ge 18 ]; then
        is_night=1
    fi

    case $id in
        # --- Clear / Sunny ---
        113)
            if [ "$is_night" -eq 1 ]; then echo "🌙"; else echo "☀"; fi
            ;;

        # --- Partly Cloudy ---
        116)
            if [ "$is_night" -eq 1 ]; then echo "☁"; else echo "🌤"; fi
            ;;

        # --- Cloudy / Overcast ---
        119|122) echo "☁" ;;

        # --- Mist / Fog / Freezing Fog ---
        143|248|260) echo "🌫" ;;

        # --- Patchy rain / Light drizzle / Light rain ---
        176|263|266|293|296|353) echo "🌦" ;;

        # --- Moderate / Heavy rain (incl. at times, showers, torrential) ---
        299|302|305|308|356|359) echo "🌧" ;;

        # --- Freezing drizzle / freezing rain (incl. light / heavy) ---
        185|281|284|311|314) echo "🌧" ;;

        # --- Sleet / Ice pellets (incl. patchy / light / moderate / heavy, showers) ---
        182|317|320|350|362|365|374|377) echo "🌨" ;;

        # --- Patchy / Light / Moderate / Heavy snow (incl. blowing / blizzard, showers) ---
        179|227|230|323|326|329|332|335|338|368|371) echo "❄" ;;

        # --- Thunder / Thundery with rain/snow (incl. nearby, patchy, moderate/heavy) ---
        200|386|389|392|395) echo "⛈" ;;

        # --- Default / Fallback ---
        *) echo "" ;;
    esac
}

# Function to fetch weather from OpenWeatherMap
fetch_weather() {
    local url="wttr.in?format=j1"

    # Fetch with 5 second timeout
    local response=$(curl -sf --max-time 30 "$url" 2>/dev/null)

    if [ $? -eq 0 ] && [ -n "$response" ]; then
        # Parse the response
        echo "$response" | jq . >/dev/null 2>&1
        local temp=$(echo "$response" | jq -r '.current_condition[0].temp_C // 0' | awk '{printf "%.0f", $1}')
        local desc=$(echo "$response" | jq -r '.weather[0].hourly[0].weatherDesc[0].value // "Unknown"')
        local weather_id=$(echo "$response" | jq -r '.weather[0].hourly[0].weatherCode // 800')
        local icon=$(get_icon "$weather_id")

        # Capitalize first letter of description
        desc="$(echo "$desc" | sed 's/^\(.\)/\U\1/')"

        # Create JSON
        local output="{\"temp\":\"${temp}°\",\"desc\":\"${desc}\",\"icon\":\"${icon}\",\"id\":${weather_id}}"

        echo "$output" > "$CACHE_FILE"
        echo "$output"
    else
        # Return cached data if fetch fails (fallback)
        if [ -f "$CACHE_FILE" ]; then
            cat "$CACHE_FILE"
        else
            echo '{\"temp\":\"--°\",\"desc\":\"Offline\",\"icon\":\"\"}'
        fi
    fi
}

# Check if cache is valid
if [ -f "$CACHE_FILE" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))
    else
        cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    fi

    if [ $cache_age -lt $CACHE_DURATION ]; then
        # Cache is valid, return it
        cat "$CACHE_FILE"
        exit 0
    fi
fi

# Cache expired or missing, fetch new data
fetch_weather
