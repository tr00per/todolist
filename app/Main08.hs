{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}

import           Data.Aeson.TH            (defaultOptions, deriveJSON)
import           Data.Text                (Text)
import           Network.Wai              (Application)
import           Network.Wai.Handler.Warp (run)
import           Servant

main :: IO ()
main = run 8080 app

app :: Application
app = serve proxy server

proxy :: Proxy ToDoApi
proxy = Proxy

server :: Server ToDoApi
server = singleTask
    :<|> allTasks

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

type ToDoApi = "task" :> QueryParam "id" TaskId :> Get '[JSON] Task
          :<|> "tasks" :> Get '[JSON] [Task]

type TaskId = Int
type TaskBody = Text

data Task = Task { taskId   :: TaskId
                 , taskBody :: TaskBody
                 } deriving (Eq, Show)

staticData :: [Task]
staticData = [ Task 1 "Kupić bułki"
             , Task 2 "Odebrać garnitur"
             ]

$(deriveJSON defaultOptions ''Task)
