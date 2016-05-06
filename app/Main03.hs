{-# LANGUAGE OverloadedStrings #-}
import           Control.Concurrent       (threadDelay)
import           Network.HTTP.Types       (status200)
import           Network.Wai              (responseStream)
import           Network.Wai.Handler.Warp (run)

application _ respond = respond $ responseStream
    status200
    [("Content-Type", "text/plain")]
    $ \send flush -> do
        send "Starting the response...\n"
        flush
        threadDelay 1000000
        send "All done!\n"

{-
We use responseStream, and our third argument is a function which takes our
"send a builder" and "flush the buffer" functions. Notice how we flush after
our first chunk of data, to make sure the client sees the data immediately.
However, there’s no need to flush at the end of a response. WAI requires that
the handler automatically flush at the end of a stream.
-}

main = run 3000 application
