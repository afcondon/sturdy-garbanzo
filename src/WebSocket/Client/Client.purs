-- | This module defines a simple low-level interface to the websockets API.

module WebSocket.Client ( newWebSocket) where

import Effect (Effect)
import Effect.Var (Var, GettableVar, SettableVar, makeVar, makeGettableVar, makeSettableVar)
import Web.Event.EventTarget (eventListener, EventListener)
import Web.Event.Internal.Types (Event)
import Web.Socket.Event.CloseEvent (CloseEvent)
import Web.Socket.Event.MessageEvent (data_, MessageEvent)
import Data.Enum (class BoundedEnum, class Enum, defaultSucc, defaultPred, toEnum, Cardinality(..))
import Foreign (unsafeFromForeign)
import Data.Function.Uncurried (runFn2, Fn2)
import Data.Functor.Invariant (imap)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Generic.Rep.Eq (genericEq)
import Data.Generic.Rep.Ord (genericCompare)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (toNullable, Nullable)
import Prelude (class Ord, compare, class Eq, eq, class Bounded, class Show, Unit, (<$>), (>>>), (>>=), ($))
import Unsafe.Coerce (unsafeCoerce)
import WebSocket.Types

-- | Initiate a websocket connection.
newWebSocket :: URL -> Array Protocol -> Effect Connection
newWebSocket url protocols = enhanceConnection <$> runFn2 newWebSocketImpl url protocols

foreign import newWebSocketImpl :: Fn2 URL
                                  (Array Protocol)
                                  (Effect ConnectionImpl)

enhanceConnection :: ConnectionImpl -> Connection
enhanceConnection c = Connection $
  { binaryType: imap toBinaryType fromBinaryType $ makeVar c.getBinaryType c.setBinaryType
  , bufferedAmount: makeGettableVar c.getBufferedAmount
  , onclose: makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnclose
  , onerror: makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnerror
  , onmessage: makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnmessage
  , onopen: makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnopen
  , protocol: makeVar c.getProtocol c.setProtocol
  , readyState: unsafeReadyState <$> makeGettableVar c.getReadyState
  , url: makeGettableVar c.getUrl
  , close: c.closeImpl (toNullable Nothing)
  , close': \code reason -> c.closeImpl (toNullable (Just { code, reason: toNullable reason }))
  , send: c.sendImpl
  , socket: makeGettableVar c.getSocket
  }
  where
    unsafeReadyState :: Int -> ReadyState
    unsafeReadyState x =
      fromMaybe (specViolation "readyState isn't in the range of valid constants")
                (toEnum x)

