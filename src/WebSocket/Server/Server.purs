-- | This module defines a simple low-level interface to the websockets API.

module WebSocket.Server ( newWebSocketServer ) where

import WebSocket.Types

import Data.Enum (toEnum)
import Data.Functor.Invariant (imap)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (toNullable)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Var (makeGettableVar, makeSettableVar, makeVar)
import Prelude (bind, pure, unit, ($), (<$>), (>>=), (>>>))
import Web.Event.EventTarget (eventListener)

foreign import _newWebSocketServer :: EffectFnAff ConnectionImpl -- add Port param once working

-- | Initiate a websocket client connection, only returns once there's actually a connection on it
newWebSocketServer :: Aff Connection 
newWebSocketServer = do
  -- connectionImpl <- liftEffect $ runFn1 _newWebSocketServer (toNumber port)
  connectionImpl <- fromEffectFnAff _newWebSocketServer -- (toNumber port)
  pure $ enhanceConnection connectionImpl


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
  , close         : c.closeImpl (toNullable Nothing)
  , close'        : \code reason -> c.closeImpl (toNullable (Just { code, reason: toNullable reason }))
  , send          : \_ -> pure unit -- c.sendImpl
  , socket        : makeGettableVar c.getSocket
  }
  where
    unsafeReadyState :: Int -> ReadyState
    unsafeReadyState x =
      fromMaybe (specViolation "readyState isn't in the range of valid constants")
                (toEnum x)
