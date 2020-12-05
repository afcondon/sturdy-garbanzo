module Main where

import Affjax (get)
import Debug.Trace (trace)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Effect.Var (($=))
import Prelude (Unit, bind, discard, unit, void, when, (==), ($), (<<<), (<>), (=<<))
import WebSocket (Connection(..), Message(..), runMessage, runMessageEvent, runURL)
import WebSocket.Server (newWebSocketServer) as ServerWS

openHandler socket event = do
    void $ trace event
    log "onopen: Connection opened"

    -- log <<< runURL =<< get socket.url

    log "onopen: Sending 'hello'"
    socket.send (Message "hello")

    log "onopen: Sending 'goodbye'"
    socket.send (Message "goodbye")

messageHandler socket event = do
    void $ trace event
    let received = runMessage (runMessageEvent event)

    log $ "onmessage: Received '" <> received <> "'"

    when (received == "goodbye") do
      log "onmessage: closing connection"
      socket.close

closeHandler socket event = do
    void $ trace event
    log "onclose: Connection closed"

main :: Effect Unit
main = launchAff_ do
  (Connection socket) <- ServerWS.newWebSocketServer 8080
  socket.onopen    $= (openHandler socket)
  socket.onmessage $= (messageHandler socket)
  socket.onclose   $= (closeHandler socket)
  liftEffect $ log "🍝"
