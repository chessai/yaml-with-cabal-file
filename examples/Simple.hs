{-# LANGUAGE OverloadedStrings #-}

module Simple where

import qualified Data.Yaml as Y

main :: IO ()
main = do
  res <- Y.decodeThrow "[1,2,3]"
  print (res :: [Integer])

-- You can go one step further and decode into a custom type by implementing
-- 'FromJSON' for that type. This is also appropriate where extra
-- normalization, formatting or manipulation of the YAML is required on decode.
