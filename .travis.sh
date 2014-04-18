#!/bin/bash

sudo apt-get install -qq git libgmp3-dev

# Git complains if it isn't configured
git config --global user.email "travis@localhost.localdomain"
git config --global user.name "travis"

git clone https://github.com/thisismiller/literate.git literate

git clone git://git.code.sf.net/p/ats2-lang/code postiats

pushd postiats
git reset --hard $ATS2_COMMIT
for file in $(ls ../.ats_patches); do
  git am ../.ats_patches/$file
done
./autogen.sh || true
./configure
make -j1
popd

export PATSHOME=$(pwd)/postiats
export UNLIT=literate/bin/unlit
export PATSOPT=postiats/bin/patsopt
export PATSCC=postiats/bin/patscc
make
