{-# LANGUAGE CPP #-}
-- | Prettier YAML encoding.
--
-- @since 0.8.13
module Data.Yaml.Pretty
    ( encodePretty
    , Config
    , getConfCompare
    , setConfCompare
    , getConfDropNull
    , setConfDropNull
    , defConfig
    ) where

import Prelude hiding (null)

#if !MIN_VERSION_base(4,8,0)
import Control.Applicative ((<$>))
#endif
import Data.Aeson.Types
import Data.ByteString (ByteString)
import Data.Function (on)
import qualified Data.HashMap.Strict as HM
import Data.List (sortBy)
#if !MIN_VERSION_base(4,8,0)
import Data.Monoid
#endif
import Data.Text (Text)
import qualified Data.Vector as V

import Data.Yaml.Builder

-- |
-- @since 0.8.13
data Config = Config
  { confCompare :: Text -> Text -> Ordering -- ^ Function used to sort keys in objects
  , confDropNull :: Bool
  }

-- | The default configuration: do not sort objects or drop keys
--
-- @since 0.8.13
defConfig :: Config
defConfig = Config mempty False

-- |
-- @since 0.8.13
getConfCompare :: Config -> Text -> Text -> Ordering
getConfCompare = confCompare

-- | Sets ordering for object keys
--
-- @since 0.8.13
setConfCompare :: (Text -> Text -> Ordering) -> Config -> Config
setConfCompare cmp c = c { confCompare = cmp }

-- |
-- @since 0.8.24
getConfDropNull :: Config -> Bool
getConfDropNull = confDropNull

-- | Drop entries with `Null` value from objects, if set to `True`
--
-- @since 0.8.24
setConfDropNull :: Bool -> Config -> Config
setConfDropNull m c = c { confDropNull = m }

pretty :: Config -> Value -> YamlBuilder
pretty cfg = go
  where go (Object o) = let sort = sortBy (confCompare cfg `on` fst)
                            select
                              | confDropNull cfg = HM.filter (/= Null)
                              | otherwise        = id
                        in mapping (sort $ HM.toList $ HM.map go $ select o)
        go (Array a)  = array (go <$> V.toList a)
        go Null       = null
        go (String s) = string s
        go (Number n) = scientific n
        go (Bool b)   = bool b

-- | Configurable 'encode'.
--
-- @since 0.8.13
encodePretty :: ToJSON a => Config -> a -> ByteString
encodePretty cfg = toByteString . pretty cfg . toJSON
