{-# LANGUAGE OverloadedStrings #-}

import           Lib06
import           Lib09
import           Network.Wai              (Application, Response, pathInfo)
import           Network.Wai.Handler.Warp (run)
import           Servant                  ((:<|>) (..), Handler, Server, err400,
                                           errBody, serve, throwError)

main :: IO ()
main = run 8080 app

app :: Application
app = serve proxy server

server :: Server ToDoApi
server = singleTask
    :<|> allTasks
    :<|> rawApp

    where allTasks :: Handler [Task]
          allTasks = return staticData

          singleTask :: Maybe TaskId -> Handler Task
          singleTask Nothing =
                throwError $ err400 { errBody = "Musisz wskazać element." }
          singleTask (Just id) =
                goodOrDie $ lookup id [(taskId task, task) | task <- staticData]

          goodOrDie :: Maybe Task -> Handler Task
          goodOrDie Nothing =
                throwError $ err400 { errBody = "Wskzany element nie istnieje." }
          goodOrDie (Just t) =
                return t

rawApp :: Application
rawApp request sendResponse = sendResponse $ dispatch $ pathInfo request
