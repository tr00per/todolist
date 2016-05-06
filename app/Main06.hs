{-# LANGUAGE OverloadedStrings #-}
import           Lib06                    (dispatch)
import           Network.Wai              (Application, pathInfo)
import           Network.Wai.Handler.Warp (run)

main :: IO ()
main = run 8080 app

app :: Application
app request sendResponse = sendResponse $ dispatch $ pathInfo request
