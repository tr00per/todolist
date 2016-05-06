{-# LANGUAGE OverloadedStrings #-}
import           Data.ByteString          (ByteString)
import           Data.ByteString.Lazy     (fromStrict)
import           Data.List                (intercalate, intersperse)
import           Data.String              (IsString)
import           Data.Text                (Text)
import           Data.Text.Encoding       (encodeUtf8)
import           Network.HTTP.Types       (Status, status200, status404)
import           Network.Wai
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 8080 app

app :: Application
app request sendResponse = sendResponse $ dispatch $ pathInfo request

dispatch :: [Text] -> Response
dispatch [] =
    htmlOk "index.html"
dispatch ["main.js"] =
    sendJs "main.js"
dispatch ["echo", msg] =
    echo msg
dispatch _ =
    htmlMissing "404.html"

echo :: Text -> Response
echo msg = responseLBS
    status200
    [ ("Content-Type", "text/plain")
    , ("X-Echo", encodeUtf8 msg)
    ]
    (fromStrict $ encodeUtf8 msg)

htmlOk, htmlMissing :: String -> Response
htmlOk = sendHtml status200
htmlMissing = sendHtml status404

sendHtml :: Status -> String -> Response
sendHtml = sendWholeFile "text/html" "html"

sendJs :: String -> Response
sendJs = sendWholeFile "text/javascript" "js" status200

sendWholeFile :: ByteString -> String -> Status -> String -> Response
sendWholeFile mime dir status path =
    responseFile status [("Content-Type", mime)] combinedPath Nothing
    where combinedPath = foldr1 mappend ["static/", dir, "/", path]
