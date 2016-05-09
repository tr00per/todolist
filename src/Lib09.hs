{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}

module Lib09 where

import           Data.Aeson.TH (defaultOptions, deriveJSON)
import           Data.Text     (Text)
import           Servant

proxy :: Proxy ToDoApi
proxy = Proxy

type ToDoApi = "task" :> QueryParam "id" TaskId :> Get '[JSON] Task
          :<|> "tasks" :> Get '[JSON] [Task]
          :<|> Raw

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
