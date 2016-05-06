{-# LANGUAGE OverloadedStrings #-}
import           Network.HTTP.Types          (status200)
import           Network.Wai                 (Application, responseFile)
import           Network.Wai.Handler.Warp    (run)
import           Network.Wai.Middleware.Gzip (def, gzip)

main :: IO ()
main = run 8080 $ gzip def app

app :: Application
app _ sendResponse = sendResponse $ responseFile
    status200
    [("Content-Type", "text/html")]
    "static/html/index.html"   -- ścieżka względem bieżącego katalogu!
    Nothing                    -- czy to odpowiedź częściowa? (nagłówek Range)

-- Lista "middleware'u":
-- https://github.com/yesodweb/wai/tree/master/wai-extra/Network/Wai/Middleware
