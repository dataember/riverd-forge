{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad
import Data.Default
import Network.Xmpp
import System.Log.Logger

main :: IO ()
main = do
    updateGlobalLogger "Pontarius.Xmpp" $ setLevel DEBUG
    result <- session
        "openfire"
        (Just (\_ -> ( [scramSha1 "username" Nothing "password"])
            , Nothing))
        def
    sess <- case result of
                Right s -> return s
                Left e -> error $ "XmppFailure: " ++ (show e)
    sendPresence def sess
    forever $ do
        msg <- getMessage sess
        case answerMessage msg (messagePayload msg) of
            Just answer -> sendMessage answer sess >> return ()
            Nothing -> putStrLn "Received message with no sender."
