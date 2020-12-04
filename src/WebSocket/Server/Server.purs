-- | This module defines a simple low-level interface to the websockets API.

module WebSocket.Server ( newWebSocketServer ) where

import WebSocket.Types

import Data.Enum (toEnum)
import Data.Function.Uncurried (Fn1, runFn1)
import Data.Functor.Invariant (imap)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (toNullable)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Var (makeGettableVar, makeSettableVar, makeVar)
import Prelude (bind, pure, unit, ($), (<$>), (>>=), (>>>))
import Web.Event.EventTarget (eventListener)

-- | Initiate a websocket client connection, only returns once there's actually a connection on it
newWebSocketServer :: Int -> Aff Connection 
newWebSocketServer port = do
  connectionImpl <- liftEffect $ runFn1 _newWebSocketServer (toNumber port)
  pure $ enhanceConnection connectionImpl

foreign import _newWebSocketServer :: Fn1 Number (Effect ConnectionImpl)

enhanceConnection :: ConnectionImpl -> Connection
enhanceConnection c = Connection $
  { binaryType    : imap toBinaryType fromBinaryType $ makeVar c.getBinaryType c.setBinaryType
  , bufferedAmount: makeGettableVar c.getBufferedAmount
  , onclose       : makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnclose
  , onerror       : makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnerror
  , onmessage     : makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnmessage
  , onopen        : makeSettableVar \f -> eventListener (coerceEvent >>> f) >>= c.setOnopen
  , protocol      : makeVar c.getProtocol c.setProtocol
  , readyState    : unsafeReadyState <$> makeGettableVar c.getReadyState
  , url           : makeGettableVar c.getUrl
  , close         : pure unit -- c.closeImpl (toNullable Nothing)
  , close'        : \code reason -> c.closeImpl (toNullable (Just { code, reason: toNullable reason }))
  , send          : \_ -> pure unit -- c.sendImpl
  , socket        : makeGettableVar c.getSocket
  }
  where
    unsafeReadyState :: Int -> ReadyState
    unsafeReadyState x =
      fromMaybe (specViolation "readyState isn't in the range of valid constants")
                (toEnum x)
