-- | This module defines a simple low-level interface to the websockets API.

module WebSocket
  ( module WebSocket.Client
  , module WebSocket.Server
  , module WebSocket.Types
  ) where

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
import WebSocket.Client
import WebSocket.Server
import WebSocket.Types


