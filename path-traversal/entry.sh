#!/usr/bin/env ysh

proc shell() {
  osh
}

proc welcome() {
  # Print a nice welcome banner, but use bat to make it look pretty
  ...
    echo '''
    **Welcome the the PATH traversal tutorial!**

    Make sure to follow along at https://aolsen.ca/writings/lets-write-a-path-traverser/

    You will have to edit some files. This container comes pre-installed with
    emacs, vim and nano. If you don't know which to choose, use nano.

    The development flow is as follows:

    1. Hack on your PATH traversal algorithm:

    ```sh
        nano traverse.py
    ```

    2. Run tests with the ./test.ysh shell script

    ```sh
        ./test.sh --help  # To see the options
    ```

    When you are done with the tutorial, close your editor and press CTRL+D (also
    written ^D) or run the 'exit' command.

    After exiting, you can return to your progress by running:

    ```sh
        podman start -ai path-traversal-tutorial
        docker start -ai path-traversal-tutorial
    ```
    '''
    | bat --style plain --language markdown --color always  # Pipe to bat for minimal styling
    | grep -v '```'  # Remove the ``` noise
    ;
}

proc main() {
  welcome
  shell
}

main
