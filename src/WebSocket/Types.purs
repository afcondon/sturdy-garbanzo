module WebSocket.Types where

import Data.Enum (class BoundedEnum, class Enum, Cardinality(..), defaultPred, defaultSucc, toEnum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Eq (genericEq)
import Data.Generic.Rep.Ord (genericCompare)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (Nullable)
import Debug.Trace (spy)
import Effect (Effect)
import Effect.Var (GettableVar, SettableVar, Var)
import Foreign (unsafeFromForeign)
import Prelude (class Bounded, class Eq, class Ord, class Show, show, Unit, compare, eq, (<>), ($))
import Unsafe.Coerce (unsafeCoerce)
import Web.Event.EventTarget (EventListener)
import Web.Event.Internal.Types (Event)
import Web.Socket.Event.CloseEvent (CloseEvent)
import Web.Socket.Event.MessageEvent (data_, MessageEvent)

foreign import specViolation :: forall a. String -> a

unsafeReadyState :: Int -> ReadyState
unsafeReadyState x = fromMaybe (specViolation "readyState isn't in the range of valid constants") (toEnum x)
  where
    _ = spy $ "checking ready state" <> show x

runMessageEvent :: MessageEvent -> Message
runMessageEvent event = unsafeFromForeign $ data_ event

type ConnectionImpl =
  { setBinaryType     :: String -> Effect Unit
  , getBinaryType     :: Effect String
  , getBufferedAmount :: Effect BufferedAmount
  , setOnclose        :: EventListener -> Effect Unit
  , setOnerror        :: EventListener -> Effect Unit
  , setOnmessage      :: EventListener -> Effect Unit
  , setOnopen         :: EventListener -> Effect Unit
  , setProtocol       :: Protocol -> Effect Unit
  , getProtocol       :: Effect Protocol
  , getReadyState     :: Effect Int
  , getUrl            :: Effect URL
  , closeImpl         :: Nullable { code :: Code, reason :: Nullable Reason } -> Effect Unit
  , sendImpl          :: Message -> Effect Unit
  , getSocket         :: Effect WebSocket
  }

coerceEvent :: forall a. Event -> a
coerceEvent = unsafeCoerce

-- | - `binaryType` -- The type of binary data being transmitted by the connection.
-- | - `bufferedAmount` -- The number of bytes of data that have been queued
-- |   using calls to `send` but not yet transmitted to the
-- |   network. This value does not reset to zero when the
-- |   connection is closed; if you keep calling `send`,
-- |   this will continue to climb.
-- | - `onclose` -- An event listener to be called when the `Connection`'s
-- |   `readyState` changes to `Closed`.
-- | - `onerror` -- An event listener to be called when an error occurs.
-- | - `onmessage` -- An event listener to be called when a message is received
-- |   from the server.
-- | - `onopen` -- An event listener to be called when the `Connection`'s
-- |   readyState changes to `Open`; this indicates that the
-- |   connection is ready to send and receive data.
-- | - `protocol` -- A string indicating the name of the sub-protocol the server selected.
-- | - `readyState` -- The current state of the connection.
-- | - `url` -- The URL as resolved by during construction. This is always an absolute URL.
-- | - `close` -- Closes the connection or connection attempt, if any.
-- |   If the connection is already CLOSED, this method does nothing.
-- |   If `Code` isn't specified a default value of 1000 (indicating
-- |   a normal "transaction complete" closure) is assumed
-- | - `send` -- Transmits data to the server.
-- | - `socket` -- Reference to closured WebSocket object.
newtype Connection = Connection
  { binaryType     :: Var BinaryType
  , bufferedAmount :: GettableVar BufferedAmount
  , onclose        :: SettableVar (CloseEvent -> Effect Unit)
  , onerror        :: SettableVar (Event -> Effect Unit)
  , onmessage      :: SettableVar (MessageEvent -> Effect Unit)
  , onopen         :: SettableVar (Event -> Effect Unit)
  , protocol       :: Var Protocol
  , readyState     :: GettableVar ReadyState
  , url            :: GettableVar URL
  , close          :: Effect Unit
  , close'         :: Code -> Maybe Reason -> Effect Unit
  , send           :: Message -> Effect Unit
  , socket         :: GettableVar WebSocket
  }


-- | A reference to a WebSocket object.
foreign import data WebSocket :: Type

-- | The type of binary data being transmitted by the connection.
data BinaryType = Blob | ArrayBuffer

toBinaryType :: String -> BinaryType
toBinaryType "blob" = Blob
toBinaryType "arraybuffer" = ArrayBuffer
toBinaryType s = specViolation "binaryType should be either 'blob' or 'arraybuffer'"

fromBinaryType :: BinaryType -> String
fromBinaryType Blob = "blob"
fromBinaryType ArrayBuffer = "arraybuffer"

-- | The number of bytes of data that have been buffered (queued but not yet transmitted)
newtype BufferedAmount = BufferedAmount Int

runBufferedAmount :: BufferedAmount -> Int
runBufferedAmount (BufferedAmount a) = a

derive instance genericBufferedAmount :: Generic BufferedAmount _
instance eqBufferedAmount :: Eq BufferedAmount where
  eq (BufferedAmount a) (BufferedAmount b) = eq a b
instance ordBufferedAmount :: Ord BufferedAmount where
  compare (BufferedAmount a) (BufferedAmount b) = compare a b

-- | A string indicating the name of the sub-protocol.
newtype Protocol = Protocol String

runProtocol :: Protocol -> String
runProtocol (Protocol a) = a

derive instance genericProtocol :: Generic Protocol _
instance eqProtocol :: Eq Protocol where
  eq (Protocol a) (Protocol b) = eq a b
instance ordProtocol :: Ord Protocol where
  compare (Protocol a) (Protocol b) = compare a b

-- | State of the connection.
data ReadyState = Connecting | Open | Closing | Closed

derive instance genericReadyState :: Generic ReadyState _

instance eqReadyState :: Eq ReadyState where
  eq = genericEq

instance ordReadyState :: Ord ReadyState where
  compare = genericCompare

instance showReadyState :: Show ReadyState where
  show = genericShow

instance boundedReadyState :: Bounded ReadyState where
  bottom = Connecting
  top    = Closed

instance boundedEnumReadyState :: BoundedEnum ReadyState where
  cardinality = Cardinality 4
  toEnum      = toEnumReadyState
  fromEnum    = fromEnumReadyState

instance enumReadyState :: Enum ReadyState where
  succ        = defaultSucc toEnumReadyState fromEnumReadyState
  pred        = defaultPred toEnumReadyState fromEnumReadyState

toEnumReadyState :: Int -> Maybe ReadyState
toEnumReadyState 0 = Just Connecting
toEnumReadyState 1 = Just Open
toEnumReadyState 2 = Just Closing
toEnumReadyState 3 = Just Closed
toEnumReadyState _ = Nothing

fromEnumReadyState :: ReadyState -> Int
fromEnumReadyState Connecting = 0
fromEnumReadyState Open       = 1
fromEnumReadyState Closing    = 2
fromEnumReadyState Closed     = 3

-- | Should be either equal to 1000 (indicating normal closure) or in the range
-- | of 3000-4999.
newtype Code
  = Code Int

runCode :: Code -> Int
runCode (Code a) = a

derive instance genericCode :: Generic Code _
instance eqCode :: Eq Code where
  eq (Code a) (Code b) = eq a b
instance ordCode :: Ord Code where
  compare (Code a) (Code b) = compare a b

-- | A human-readable string explaining why the connection is closing. This
-- | string must be no longer than 123 bytes of UTF-8 text (not characters).
newtype Reason = Reason String

runReason :: Reason -> String
runReason (Reason a) = a

derive instance genericReason :: Generic Reason _

-- | A synonym for URL strings.
newtype URL = URL String

runURL :: URL -> String
runURL (URL a) = a

derive instance genericURL :: Generic URL _

-- | A synonym for message strings.
newtype Message = Message String
derive instance genericMessage :: Generic Message _

runMessage :: Message -> String
runMessage (Message a) = a
