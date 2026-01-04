import argparse
import sys

import traverse

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('name')
    parser.add_argument('path')
    args = parser.parse_args()

    if result := traverse.lookup_executable(args.name, args.path):
        print(result)
    else:
        print("Not found")
        sys.exit(1)
