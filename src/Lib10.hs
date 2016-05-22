{-# LANGUAGE EmptyDataDecls             #-}
{-# LANGUAGE FlexibleContexts           #-}
{-# LANGUAGE GADTs                      #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses      #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE QuasiQuotes                #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}

module Lib10 where

import           Control.Monad.IO.Class  (liftIO)
import           Data.Text
import           Database.Persist        (Entity (Entity), Key,
                                          SelectOpt (LimitTo), get, insert,
                                          selectList, (==.), delete, deleteWhere)
import           Database.Persist.Sqlite (runMigration, runSqlite)
import           Database.Persist.TH     (mkMigrate, mkPersist,
                                          persistLowerCase, share, sqlSettings)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Task
    body Text
    done Bool
    deriving Show
Person
    name String
    age Int Maybe
    deriving Show
BlogPost
    title String
    authorId PersonId
    deriving Show
|]

connect = connectSqlite3 "test.db3"

migrate :: IO ()
migrate = runSqlite "todo.sqlite" $ runMigration migrateAll

insertData :: IO (Key Person, Key Person)
insertData = runSqlite "todo.sqlite" $ do
    johnId <- insert $ Person "John Doe" $ Just 35
    janeId <- insert $ Person "Jane Doe" Nothing

    insert $ BlogPost "My fr1st p0st" johnId
    insert $ BlogPost "One more for good measure" johnId

    return (johnId, janeId)

selectData :: Key Person -> IO ()
selectData johnId = runSqlite "todo.sqlite" $ do
    oneJohnPost <- selectList [BlogPostAuthorId ==. johnId] [LimitTo 1]
    liftIO $ print (oneJohnPost :: [Entity BlogPost])

    john <- get johnId
    liftIO $ print (john :: Maybe Person)

cleanupData :: Key Person -> Key Person -> IO ()
cleanupData johnId janeId = runSqlite "todo.sqlite" $ do
    delete janeId
    deleteWhere [BlogPostAuthorId ==. johnId]
