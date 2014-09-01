module Main where

import Network.URI (URI)
import Dep (produceURI)

consumeURI :: URI -> IO ()
consumeURI = undefined

main :: IO ()
main = consumeURI produceURI
