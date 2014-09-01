#! /usr/bin/env bash
cabal sandbox init
cabal sandbox add-source ../dep3
cabal --require-sandbox install -j --only-dependencies
cabal build
