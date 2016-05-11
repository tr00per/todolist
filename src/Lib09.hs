{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeOperators     #-}

module Lib09
( proxy
, ToDoApi (..)
, Task (..)
, TaskId
, staticData
) where

import           Data.Aeson.TH (defaultOptions, deriveJSON)
import           Data.Text     (Text)
import           Servant

proxy :: Proxy ToDoApi
proxy = Proxy

type ToDoApi = "task" :> QueryParam "id" TaskId :> Get '[JSON] Task
          :<|> "tasks" :> Get '[JSON] [Task]
          :<|> Raw -- przekazanie sterowania do innej aplikacji WAI

type TaskId = Int
type TaskBody = Text
type TaskFlag = Bool

data Task = Task { taskId   :: TaskId
                 , taskBody :: TaskBody
                 , taskDone :: TaskFlag
                 } deriving (Eq, Show)

staticData :: [Task]
staticData = [ Task 1 "Kupić bułki" False
             , Task 2 "Odebrać garnitur" False
             , Task 3 "Naprawić okulary" True
             ]

$(deriveJSON defaultOptions ''Task)
