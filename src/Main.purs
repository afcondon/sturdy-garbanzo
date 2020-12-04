module Main where

import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Prelude (Unit, bind, ($))
import WebSocket (Connection(..))
import WebSocket.Server (newWebSocketServer) as ServerWS


main :: Effect Unit
main = launchAff_ do
  socket <- ServerWS.newWebSocketServer -- 8080
  liftEffect $ log "🍝"
