{-# LANGUAGE OverloadedStrings #-}
import           Blaze.ByteString.Builder           (fromByteString)
import           Blaze.ByteString.Builder.Char.Utf8 (fromShow)
import           Control.Concurrent.MVar            (modifyMVar, newMVar)
import           Data.Monoid                        ((<>))
import           Network.HTTP.Types                 (status200)
import           Network.Wai                        (responseBuilder)
import           Network.Wai.Handler.Warp           (run)

application countRef _ respond =
    modifyMVar countRef $ \count -> do
        let count' = count + 1
            msg = fromByteString "You are visitor number: " <>
                  fromShow count'
        responseReceived <- respond $ responseBuilder
            status200
            [("Content-Type", "text/plain")]
            msg
        return (count', responseReceived)

{-
Notice how we take advantage of Builders in constructing our msg value.

Instead of concatenating two ByteStrings together directly, we monoidally append
two different Builder values. The advantage to this is that the results will
end up being copied directly into the final output buffer, instead of first
being copied into a temporary ByteString buffer to only later be copied into
the final buffer.
-}

main = do
    visitorCount <- newMVar 0
    run 3000 $ application visitorCount
