#!/usr/bin/python

# We need binascii to convert the path and app name to crc32 and sys to
# get the command line arguments
import binascii
import sys


def get_app_id(exe, appname):
    """Get APP ID for non-steam shortcut.

    get_api_id(file, str, str) -> int
    """
    comboString = ''.join([exe, appname])
    id_int = binascii.crc32(str.encode(comboString)) | 0x80000000
    
    return id_int


if __name__ == "__main__":
    # If there aren't the correct number of arguments, fail with error
    if len(sys.argv) != 3:
        sys.exit("Not enough arguments")
    print(get_app_id(sys.argv[1], sys.argv[2]))
