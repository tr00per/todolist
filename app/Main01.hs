{-# LANGUAGE OverloadedStrings #-}
import           Network.HTTP.Types       (status200)
import           Network.Wai              (Application, responseLBS)
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 8080 app

app :: Application
app _ sendResponse = sendResponse $ responseLBS
    status200
    [("Content-Type", "text/plain")]
    "Hello Warp!"
