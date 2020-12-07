module Main where

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Var (($=))
import Prelude (Unit, bind, discard, pure, unit, when, ($), (<>), (==))
import Web.Socket.Event.MessageEvent (MessageEvent)
import WebSocket (Connection(..), Message(..), URL(..))
import WebSocket (newWebSocket) as ClientWS
import WebSocket.Server (newWebSocketServer, tryDecodeMessage) as ServerWS

sendMessage :: Connection -> String -> Effect Unit
sendMessage = \(Connection ws) msg -> ws.send (Message msg)

openHandler :: forall e. Connection -> e -> Effect Unit
openHandler socket = \event -> do
  log "onopen: Sending 'hello'"
  socket `sendMessage` "hello"

  log "onopen: Sending 'goodbye'"
  socket `sendMessage` "goodbye"

messageHandler :: Connection -> MessageEvent -> Effect Unit
messageHandler (Connection socket) = \event -> do
  case ServerWS.tryDecodeMessage event of
    Just received -> do
        log $ "onmessage: Received '" <> received <> "'"
        when (received == "goodbye\n") do
          log "onmessage: closing connection"
          socket.close -- not working yet, apparently?
    Nothing -> pure unit

closeHandler :: forall e. Connection -> e -> Effect Unit
closeHandler _ = \event -> do
    log "onclose: Connection closed"

setHandlers :: Connection -> Effect Unit
setHandlers c@(Connection socket) = do
  socket.onopen    $= openHandler c
  socket.onmessage $= messageHandler c
  socket.onclose   $= closeHandler c

main :: Effect Unit
main = launchAff_ do
  clientSocket <- liftEffect $ ClientWS.newWebSocket (URL "ws://localhost:8888") []
  serverSocket <- ServerWS.newWebSocketServer 8080
  liftEffect $ setHandlers serverSocket
  liftEffect $ sendMessage serverSocket "reach out, i'll be there"
  liftEffect $ log "...and now we listen"
