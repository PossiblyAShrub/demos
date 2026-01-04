#!/usr/bin/env ysh

# We want to build a tree like this:
# .
# ├── bin
# │   ├── extra
# │   │   └── extra
# │   └── hello
# └── other-bin
#     ├── extra
#     │   └── hello
#     └── hello

mkdir -p bin/extra other-bin/extra

cat >bin/extra/extra <<EOF
#!/usr/bin/env sh

echo 'Extra extra! Read all about it!'
EOF

cat >bin/hello <<EOF
#!/usr/bin/env sh

echo hi
EOF

cat >other-bin/extra/hello <<EOF
This is not an executable
EOF

cat >other-bin/hello <<EOF
#!/usr/bin/env sh

echo 'Hey! This is the other hello script!'
EOF

# Set these files as executable
for f in bin/extra/extra bin/hello other-bin/hello {
  chmod +x $f
}
