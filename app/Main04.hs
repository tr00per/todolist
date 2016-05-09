{-# LANGUAGE OverloadedStrings #-}

import           Blaze.ByteString.Builder           (fromByteString)
import           Blaze.ByteString.Builder.Char.Utf8 (fromShow)
import           Control.Concurrent.MVar            (modifyMVar, newMVar)
import           Data.Monoid                        ((<>))
import           Network.HTTP.Types                 (status200)
import           Network.Wai                        (responseBuilder)
import           Network.Wai.Handler.Warp           (run)

main = do
    visitorCount <- newMVar 0
    run 8080 $ application visitorCount

application countRef _ sendResponse =
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
