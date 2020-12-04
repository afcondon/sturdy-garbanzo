module Main where

import Effect.Aff (launchAff_)
import Prelude (Unit, bind, ($))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Console (log)
import WebSocket (Connection(..))
import WebSocket.Server (newWebSocketServer) as ServerWS


main :: Effect Unit
main = launchAff_ do
  socket@(Connection ws) <- ServerWS.newWebSocketServer 12345
  liftEffect $ log "🍝"
