#!/usr/bin/env ysh

source $LIB_YSH/yblocks.ysh
use $LIB_YSH/args.ysh

# This at-end mechanism is used to cleanup tests

var atend = []
proc at-end(;;; block) {
  ## Add a hook to the trigger-at-end list
  call atend->append(block)
}

proc trigger-at-end {
  ## Call all hooks added to trigger-at-end in reverse order

  call atend->reverse()

  for hook in (atend) {
    call io->eval(hook)
  }

  call atend->clear()
}

proc run(name, path) {
  ## Run the program with $name as the command and $path as the PATH list

  printf '$ python3 driver.py %s %s\n' $name $path >&2

  try {
    # We copy stdout to stderr so that print()s are visible
    python3 driver.py $name $path | tee /dev/stderr
  }
  if failed {
    fail "driver.py exited with a non-zero exit code"
  }
}

var tests = []

proc testcase(name;;; body) {
  ## Create a test-case with a given $name

  call tests->append({ name, body })
}

var currentTest = null
proc fail(message) {
  ## Raise a test-case failure

  echo >&2
  echo "FAIL: $[currentTest.name]: $message" >&2
  return 1
}

proc expect (name, path;; result) {
  ## Wrapper around `fail` which asserts the output of the program (ran with `run`).

  yb-capture (&actual) {
    run $name $path
  }

  if (actual.stdout !== result ++ \n) {
    fail "Expected $result but got $[actual.stdout]"
  }

  if (actual.status !== 0) {
    fail "Exited with status $[actual.status]"
  }
}

proc dir (path;;; block=null) {
  ## Create a directory at $path and run the $block in it.

  mkdir -p $path

  var abspath = $(realpath $path)
  at-end {
    rm -r $abspath
  }

  if (block is null) {
    return
  }

  cd $path {
    call io->eval(block)
  }
}

proc executable(path) {
  ## Create an executable file at $path

  printf '#!/usr/bin/env sh\necho hi\n' >$path
  chmod +x $path

  var abspath = $(realpath $path)
  at-end {
    rm $abspath
  }
}

proc runtests(...argv) {
  ## Test runner main. Call with `runtests @ARGV`

  args parser (&spec) {
    flag -f --filter (Str)
    flag -h --help (Bool)
  }

  var opts = args.parseArgs(spec, argv)

  if (opts.help) {
    echo '''
      NAME
             test.sh — Run path-traversal test cases

      SYNOPSIS
             ./test.sh [-f] [-h]

      OPTIONS
             Without any options, this utility will run all the tests.

	    To add or change test cases, edit the cases at the end of test.sh.

             -h --help          Display this help message.

             -f --filter query  Only run tests with names matching the query.
                                Matching is by case-sensitive substring.

      '''
    return
  }

  echo 'Running tests'

  var passes = 0
  var fails = 0
  for test in (tests) {
    var filter = opts.filter
    if (opts.filter and test.name.search(/ @filter /) is null) {
      continue
    }

    echo
    echo "==== $[test.name] ===="

    setglobal currentTest = test
    try {
      call io->eval(test.body)
    }
    if failed {
      setvar fails += 1

      echo 'Note: the above test had the directory structure:'
      tree /test
    } else {
      setvar passes += 1

      echo 'PASS'
    }

    trigger-at-end
  }

  echo
  echo '============'
  echo "Pass: $passes"
  echo "Fail: $fails"

  if (fails > 0) {
    exit 1
  }
}

# --------------- Test Cases ---------------

testcase "1 path, 1 executable" {
  dir /test {
    executable hello
  }

  expect hello "/test" (result="/test/hello")
}

testcase "2 paths, different executable" {
  dir /test {
    dir path1 {
      executable hello
    }

    dir path2 {
      executable hi
    }
  }

  expect hello "/test/path1:/test/path2" (result="/test/path1/hello")
}

testcase "2 paths, same executable name (order matters!)" {
  dir /test {
    dir path1 {
      executable hello
    }

    dir path2 {
      executable hello
    }
  }

  expect hello "/test/path1:/test/path2" (result="/test/path1/hello")
}

testcase "PATH can contain missing directories!" {
  dir /test {
    dir path1 {
      executable hello
    }

    dir path2 {
      executable hello
    }
  }

  expect hello "/test/path3:/test/path2" (result="/test/path2/hello")
}

testcase "Directories aren't executable" {
  dir /test {
    dir path1 {
      dir hello
    }

    dir path2 {
      executable hello
    }
  }

  expect hello "/test/path1:/test/path2" (result="/test/path2/hello")
}

runtests @ARGV
