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
-- import           Network.Wai.Middleware.Gzip

main :: IO ()
main = run 8080 app

-- compress :: GzipSettings
-- compress = def { gzipFiles = GzipCompress }

app :: Application
app request sendResponse = sendResponse $ dispatch $ pathInfo request

dispatch :: [Text] -> Response
dispatch [] =
    htmlOk "index.html"
dispatch ["main.js"] =
    sendJs "main.js"
dispatch _ =
    htmlMissing "404.html"

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
    where combinedPath = foldr1 (++) ["static/", dir, "/", path]

-- 1. Dodać obsługę kompresji odpowiedzi z niedomyślnymi opcjami
-- 2. Umożliwić zapytanie o dowolny pliku z wybranego katalogu
-- 3. Zabezpieczyć funkcję z poprzedniego punktu przed przechodzeniem do wyższego pozimu katalogów
-- 4. Dodać końcówkę /echo/<xxx>, który zwróci do użytkownika to <xxx>
-- 5. Końcówka z poprzedniego punktu powinna zwracać <xxx> w nagłówku X-Echo
