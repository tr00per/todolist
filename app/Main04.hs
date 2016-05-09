{-# LANGUAGE OverloadedStrings #-}

import           Blaze.ByteString.Builder           (fromByteString)
import           Blaze.ByteString.Builder.Char.Utf8 (fromShow)
import           Control.Concurrent.MVar            (MVar, modifyMVar, newMVar)
import           Data.Monoid                        ((<>))
import           Network.HTTP.Types                 (status200)
import           Network.Wai                        (Application,
                                                     responseBuilder)
import           Network.Wai.Handler.Warp           (run)

main :: IO ()
main = do
    visitorCount <- newMVar 0
    run 8080 $ app visitorCount

app :: MVar Int -> Application
app countRef _ sendResponse =
    modifyMVar countRef $ \count -> do
        let count' = count + 1
            -- łączenie ze sobą builderów oszczędza pamięć, mniej obiektów tymczasowych
            msg = fromByteString "You are visitor number: " <>
                  fromShow count'
        responseReceived <- sendResponse $ responseBuilder
            status200
            [("Content-Type", "text/plain")]
            msg
        return (count', responseReceived)
