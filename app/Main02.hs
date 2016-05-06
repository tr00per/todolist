{-# LANGUAGE OverloadedStrings #-}
import           Network.HTTP.Types       (status200)
import           Network.Wai              (Application, responseFile)
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 8080 app

app :: Application
app _ sendResponse = sendResponse $ responseFile
    status200
    [("Content-Type", "text/html")]
    "static/html/index.html"   -- ścieżka względem bieżącego katalogu!
    Nothing                    -- czy to odpowiedź częściowa? (nagłówek Range)
