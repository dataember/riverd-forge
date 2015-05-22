{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Monad
import Data.Default
import Network
import Network.Xmpp
import Network.Xmpp.Internal
import System.Log.Logger

main :: IO ()
main = do
    updateGlobalLogger "Pontarius.Xmpp" $ setLevel DEBUG
    result <- session
        "openfire"
        (Just (\_ -> ([plain "admin" Nothing "test"])
            , Nothing))
        def {
            sessionStreamConfiguration = def {
                connectionDetails = UseHost "openfire" (PortNumber 5222)
                , tlsBehaviour = PreferPlain
            }
        }
    sess <- case result of
                Right s -> return s
                Left e -> error $ "XmppFailure: " ++ (show e)
    sendPresence def sess
    forever $ do
        msg <- getMessage sess
        case answerMessage msg (messagePayload msg) of
            Just answer -> sendMessage answer sess >> return ()
            Nothing -> putStrLn "Received message with no sender."
