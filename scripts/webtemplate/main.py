#! /usr/bin/python3

import os
import sys


def read_template(template_file) -> str | None:
    """
    Read the template file and return the content
    """
    path = os.path.dirname(os.path.abspath(__file__))

    if not template_file.endswith(".py"):
        template_file += ".py"

    try:
        with open(path + "/" + template_file, "r") as f:
            template = f.read()
        return template
    except Exception as e:
        print(f"Error: {e}")
        return None


def write_template(dest_path: str, template: str) -> bool:
    """
    Write the template to the destination path
    """

    if dest_path[-1] != "/":
        dest_path += "/"

    try:
        with open(dest_path + "main.py", "w") as f:
            f.write(template)
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False


def main(dest_path: str,template_file: str):
    template = read_template(template_file)
    if template:
        write_template(dest_path, template)
    else:
        exit(1)


if __name__ == "__main__":
    template_file = sys.argv[1]
    dest_path = sys.argv[2]

    if not dest_path or not template_file:
        print("Usage: python3 main.py <template_file> <destination_directory>")
        exit(1)

    main(dest_path,template_file)
