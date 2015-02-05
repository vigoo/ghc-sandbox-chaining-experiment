#!/bin/bash 

# Test scenario
#
# lib1 is a simple library without dependencies
# lib2 depends on external library (ansi-wl-pprint)
# app depends on both lib1 and lib2

function initCustomSandbox {
	rm -rf .custom-sandbox
	mkdir -pv .custom-sandbox/packages
	mkdir -pv .custom-sandbox/files
	ghc-pkg --package-db=.custom-sandbox/packages recache
	root=$(pwd)
	customsandbox="--package-db=.custom-sandbox/packages --prefix=${root}/.custom-sandbox/files"
}

function stage {
	echo
	echo "******** $1 ********"
	echo
}

# Creating and building the sandboxes
stage "Building lib1"

pushd lib1
initCustomSandbox
cabal install ${customsandbox}
popd

stage "Building lib2"

pushd lib2
initCustomSandbox
cabal install ${customsandbox}
popd

stage "Building app"

pushd app
initCustomSandbox
cabal install ${customsandbox} --package-db=../lib2/.custom-sandbox/packages --package-db=../lib1/.custom-sandbox/packages

# Running the built app
stage "Running app"

.custom-sandbox/files/bin/app
popd

# Printing resulting package databases
stage "Result sandboxes"

ghc-pkg list --package-db=./lib1/.custom-sandbox/packages
ghc-pkg list --package-db=./lib2/.custom-sandbox/packages
ghc-pkg list --package-db=./app/.custom-sandbox/packages
