#!/bin/bash
ATS2_HEAD=00b8bbbcf8bcc6f320728a667ec3ca511aa50cac

sudo apt-get install -qq git libgmp3-dev

git clone https://github.com/thisismiller/literate.git literate

git clone git://git.code.sf.net/p/ats2-lang/code postiats

pushd postiats
git checkout $ATS2_HEAD
./autogen.sh || true
./configure
make -j1
popd

export PATSHOME=$(pwd)/postiats
export UNLIT=literate/bin/unlit
export ATSOPT=postiats/bin/patsopt
export ATSCC=postiats/bin/patscc
make
