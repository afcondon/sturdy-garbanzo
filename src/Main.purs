module Main where

import Affjax (get)
import Debug.Trace (trace)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Var (($=))
import Node.Express.Types (Event)
import Prelude (Unit, bind, discard, pure, unit, void, when, ($), (<<<), (<>), (=<<), (==))
import Web.Socket.Event.MessageEvent (MessageEvent)
import WebSocket (Connection(..), Message(..), runMessage, runMessageEvent, runURL)
import WebSocket.Server (newWebSocketServer) as ServerWS


openHandler :: forall e. Connection -> e -> Effect Unit
openHandler (Connection socket) event = do
  trace { fn: "openHandler", event: event } \_ -> pure unit
  pure unit
  -- void $ trace event
  -- log "onopen: Connection opened"

  -- -- log <<< runURL =<< get socket.url

  -- log "onopen: Sending 'hello'"
  -- socket.send (Message "hello")

  -- log "onopen: Sending 'goodbye'"
  -- socket.send (Message "goodbye")

messageHandler :: MessageEvent -> Effect Unit
messageHandler event = do
  trace { fn: "messageHandler", event: event } \_ -> pure unit
  pure unit
  -- let received = runMessage (runMessageEvent event)

  -- log $ "onmessage: Received '" <> received <> "'"

  -- when (received == "goodbye") do
  --   log "onmessage: closing connection"
  --   socket.close

closeHandler :: forall e. Connection -> e -> Effect Unit
closeHandler (Connection socket) event = do
  trace { fn: "messageHandler", event: event } \_ -> pure unit
  pure unit
    -- void $ trace event
    -- log "onclose: Connection closed"

setHandlers :: Connection -> Effect Unit
setHandlers c@(Connection socket) = do
  socket.onopen    $= openHandler c
  socket.onmessage $= messageHandler
  socket.onclose   $= closeHandler c

sendMessage (Connection socket) msg = socket.send $ Message msg

main :: Effect Unit
main = launchAff_ do
  socket <- ServerWS.newWebSocketServer 8080
  liftEffect $ setHandlers socket
  liftEffect $ socket `sendMessage` "foo"
  liftEffect $ (\(Connection ws) msg -> ws.send (Message msg)) socket "bar" 
  liftEffect $ log "🍝"
