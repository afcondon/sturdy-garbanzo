-- | This module defines a simple low-level interface to the websockets API.

module WebSocket.Server ( newWebSocketServer, tryDecodeMessage ) where

import WebSocket.Types

import Data.Function.Uncurried (Fn1, runFn1)
import Data.Functor.Invariant (imap)
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.Nullable (toNullable)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Effect.Var (makeGettableVar, makeSettableVar, makeVar)
import Prelude (bind, pure, ($), (<$>), (>>=), (>>>))
import Unsafe.Coerce (unsafeCoerce)
import Web.Event.EventTarget (eventListener)
import Web.Socket.Event.MessageEvent (MessageEvent)

foreign import _newWebSocketServer :: Fn1 Number (EffectFnAff ConnectionImpl)

-- NB seems like MessageEvent in nodes `ws` library isn't actually the same as that in 
-- browser which is what is modelled in Web.Socket.Event.MessageEvent??? 
-- TODO confirm this and explicitly distinguish the types and provide different runMessage
tryDecodeMessage :: MessageEvent -> Maybe String
tryDecodeMessage event = Just $ unsafeCoerce event -- TODO look into the contents

-- | Initiate a websocket client connection, only returns once there's actually a connection on it
newWebSocketServer :: Int -> Aff Connection 
newWebSocketServer port = do
  connectionImpl <- fromEffectFnAff (runFn1 _newWebSocketServer(toNumber port))
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
  , send          : c.sendImpl
  , socket        : makeGettableVar c.getSocket
  }
