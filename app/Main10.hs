{-# LANGUAGE OverloadedStrings #-}

import           Lib10
import           Network.Wai              (Application, Response, pathInfo)
import           Network.Wai.Handler.Warp (run)
import           Servant                  ((:<|>) (..), Handler, Server, err400,
                                           errBody, serve, throwError)

main :: IO ()
main = do
    migrate
    -- (johnId, janeId) <- insertData
    -- selectData johnId
    -- cleanupData johnId janeId
