#!/usr/bin/python3
import random
import string

import requests

BASE_URL = ""
URL_HOOK = ""

s = requests.Session()

def string_generator(length):
    return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(length))

def main():
	pass


if __name__ == "__main__":
	main()


# goodluck by @akiidjk
