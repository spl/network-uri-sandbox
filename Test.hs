module Test where

import qualified Network.URI as U
import qualified Network.HTTP.Client.Internal as C

main :: IO ()
main = do
  let path :: U.URI
      Just path = U.parseRelativeReference "path"
  req <- C.parseUrl "http://www.example.com"
  req' <- C.setUriRelative req path
  print req'
