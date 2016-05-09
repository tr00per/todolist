{-# LANGUAGE OverloadedStrings #-}

import           Control.Concurrent       (threadDelay)
import           Network.HTTP.Types       (status200)
import           Network.Wai              (Application, responseStream)
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 8080 app

app :: Application
app _ sendResponse = sendResponse $ responseStream
    status200
    [("Content-Type", "text/plain")]
    $ \send flush -> do
        send "Starting the response...\n"
        flush
        threadDelay 1000000
        send "All done!\n"
        -- na końcu jest automatyczny flush

-- send :: Builder -> IO ()
-- flush :: IO ()
