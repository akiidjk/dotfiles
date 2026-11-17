#!/bin/sh
# Spatial Audio 360 (PipeWire binaural virtual surround for headphones)
# Uses PipeWire's built-in filter-chain with Hilbert transform phase shifter.
set -eu

CONF_DIR="$HOME/.config/pipewire/pipewire.conf.d"
CONF_FILE="$CONF_DIR/99-spatial-audio.conf"

status() {
    if [ -f "$CONF_FILE" ]; then
        echo "on"
    else
        echo "off"
    fi
}

enable() {
    mkdir -p "$CONF_DIR"
    cat > "$CONF_FILE" <<'EOF'
# Spatial Audio 360 - Virtual Surround Sink for Headphones
context.modules = [
  {
    name = libpipewire-module-filter-chain
    flags = [ nofail ]
    args = {
      node.description = "Spatial 360 Audio"
      media.name = "Spatial 360 Audio"
      filter.graph = {
        nodes = [
          { type = builtin, name = mixer_fc, label = mixer },
          { type = builtin, name = mixer_s, label = mixer },
          {
            type = builtin
            name = s_phased
            label = convolver
            config = { filename = "/hilbert", length = 90 }
          },
          {
            type = builtin
            name = mixer_lt
            label = mixer
            control = { "Gain 1" = 1, "Gain 2" = 0, "Gain 3" = 0.70710678, "Gain 4" = -0.70710678 }
          },
          {
            type = builtin
            name = mixer_rt
            label = mixer
            control = { "Gain 1" = 0, "Gain 2" = 1, "Gain 3" = 0.70710678, "Gain 4" = 0.70710678 }
          }
        ]
        links = [
          { output = "mixer_fc:Out", input = "mixer_lt:In 3" },
          { output = "mixer_fc:Out", input = "mixer_rt:In 3" },
          { output = "mixer_s:Out",  input = "s_phased:In" },
          { output = "s_phased:Out", input = "mixer_lt:In 4" },
          { output = "s_phased:Out", input = "mixer_rt:In 4" }
        ]
        inputs  = [ "mixer_lt:In 1", "mixer_rt:In 2", "mixer_fc:In 1", "mixer_fc:In 2", "mixer_s:In 1", "mixer_s:In 2" ]
        outputs = [ "mixer_lt:Out", "mixer_rt:Out" ]
      }
      capture.props = {
        node.name   = "effect_input.spatial_360"
        media.class = Audio/Sink
        audio.channels = 6
        audio.position = [ FL, FR, FC, LFE, SL, SR ]
      }
      playback.props = {
        node.name    = "effect_output.spatial_360"
        node.passive = true
        audio.channels = 2
        audio.position = [ FL, FR ]
      }
    }
  }
]
EOF
    systemctl --user restart pipewire.service 2>/dev/null || true
    echo "Spatial Audio 360 enabled"
}

disable() {
    rm -f "$CONF_FILE"
    systemctl --user restart pipewire.service 2>/dev/null || true
    echo "Spatial Audio 360 disabled"
}

case "${1:-status}" in
    status) status ;;
    enable) enable ;;
    disable) disable ;;
    toggle)
        if [ "$(status)" = "on" ]; then
            disable
        else
            enable
        fi
        ;;
    *) echo "usage: $0 status | enable | disable | toggle" >&2; exit 2 ;;
esac
