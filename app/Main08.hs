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
          singleTask (Just tid) =
                case lookup tid [(taskId task, task) | task <- staticData] of
                    Nothing ->
                        throwError $ err400 { errBody = "Wskazany element nie istnieje." }
                    (Just t) ->
                        return t

type ToDoApi = "task" :> QueryParam "id" TaskId :> Get '[JSON] Task
          :<|> "tasks" :> Get '[JSON] [Task]

type TaskId = Int
type TaskBody = Text
type TaskState = Bool

data Task = Task { taskId   :: TaskId
                 , taskBody :: TaskBody
                 , taskDone :: TaskState
                 } deriving (Eq, Show)

staticData :: [Task]
staticData = [ Task 1 "Kupić bułki" False
             , Task 2 "Odebrać garnitur" False
             , Task 3 "Naprawić okulary" True
             ]

$(deriveJSON defaultOptions ''Task)

-- 1. Dodać obsługę sytuacji, w której nie został podany ID pojedynczego zadania
-- 2. Zamienić wyrażenie listowe w wywołaniu lookup na mapowanie
