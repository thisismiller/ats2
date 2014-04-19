#!/bin/bash

sudo apt-get install -qq git subversion libgmp3-dev

# Git complains if it isn't configured
git config --global user.email "travis@localhost.localdomain"
git config --global user.name "travis"

svn export svn://svn.code.sf.net/p/ats-lang/code/trunk anariats
svn export svn://svn.code.sf.net/p/ats-lang/code/bootstrap/anairiats anariats/bootstrap0

pushd anariats
  make
popd

export ATSHOME=$(pwd)/anariats
# This should be stable given that development is now focused on ATS2
export ATSHOMERELOC=ATS-0.2.11

git clone https://github.com/githwxi/ATS-Postiats.git postiats

pushd postiats
#git reset --hard $ATS2_COMMIT
for file in $(ls ../.ats_patches); do
  git am ../.ats_patches/$file
done
./autoreconf -i || true
./configure
make -f Makefile_devl
popd

git clone https://github.com/thisismiller/literate.git literate

export PATSHOME=$(pwd)/postiats
export UNLIT=literate/bin/unlit
export PATSOPT=postiats/bin/patsopt
export PATSCC=postiats/bin/patscc
make
