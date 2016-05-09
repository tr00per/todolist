{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators     #-}

import           Data.Aeson               (ToJSON)
import           Data.Text                (Text)
import           GHC.Generics             (Generic)
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
server = return staticData

type ToDoApi = "tasks" :> Get '[JSON] [Task]

type TaskId = Int
type TaskBody = Text

data Task = Task { taskId   :: TaskId
                 , taskBody :: TaskBody
                 } deriving (Eq, Show, Generic)

staticData :: [Task]
staticData = [ Task 1 "Kupić bułki"
             , Task 2 "Odebrać garnitur"
             ]

instance ToJSON Task
