#! /usr/bin/env bash
for d in */; do
  pushd "$d"
  cabal clean
  rm -rf .cabal-sandbox cabal.sandbox.config
  popd
done
