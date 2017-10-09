#! /bin/bash

set -e
# Start compile or execute given command
if [ "$#" -eq 0 ]; then
  pushd /opt/compile/dlib
  rm -rf build dist
  mkdir build
  cd build
  cmake .. -DUSE_AVX_INSTRUCTIONS=1
  cmake --build .
  cd ..
  python3 setup.py bdist_wheel --yes USE_AVX_INSTRUCTIONS
else
  echo "Calling $@"
  "$@"
fi
