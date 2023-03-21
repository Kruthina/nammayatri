{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Services.API where

import Control.Alt ((<|>))
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Foreign (ForeignError(..), fail)
import Foreign.Class (class Decode, class Encode, decode, encode)
import Foreign.Generic (decodeJSON)
import Prelude (class Show, show, ($), (<$>))
import Presto.Core.Types.API (class RestEndpoint, class StandardEncode, ErrorPayload, Method(..), defaultDecodeResponse, defaultMakeRequest, standardEncode)
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)
import Types.EndPoint as EP


newtype ErrorPayloadWrapper = ErrorPayload ErrorPayload

instance decodeErrorPayloadWrapper :: Decode ErrorPayloadWrapper 
  where decode payload = ErrorPayload <$> decode payload

data APIResponse a b = APISuccess a | APIError b

instance showAPIResponse :: (Show a, Show b) => Show (APIResponse a b) where
  show (APISuccess a) = show a
  show (APIError b) = show b

instance encodeAPIResponse :: (Encode a, Encode b) => Encode (APIResponse a b) where
  encode (APISuccess a) = encode a
  encode (APIError b) = encode b

instance decodeAPIResponse :: (Decode a, Decode b) => Decode (APIResponse a b) where
  decode fgn = (APISuccess <$> decode fgn) <|> (APIError <$> decode fgn) <|> (fail $ ForeignError "Unknown response")

data RetryAPIs  = NoRetry | RetryInfo Int Number -- Retry times, Delay --  TODO: need to add overall timeout and handle

derive instance genericRetryAPIs :: Generic RetryAPIs _
instance showRetryAPIs :: Show RetryAPIs where show = genericShow
instance decodeRetryAPIs :: Decode RetryAPIs where decode = defaultDecode
instance encodeRetryAPIs :: Encode RetryAPIs where encode = defaultEncode

-------------------------------------------------- Trigger OTP API Types --------------------------------------------
newtype TriggerOTPResp = TriggerOTPResp {
    authId :: String
  , attempts :: Int
}

newtype TriggerOTPReq = TriggerOTPReq {
    mobileNumber :: String
  , mobileCountryCode :: String
  , merchantId :: String
}

instance makeTriggerOTPReq :: RestEndpoint TriggerOTPReq TriggerOTPResp where
 makeRequest reqBody headers = defaultMakeRequest POST (EP.triggerOTP "") headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericTriggerOTPResp :: Generic TriggerOTPResp _
derive instance newtypeTriggerOTPResp :: Newtype TriggerOTPResp _
instance standardEncodeTriggerOTPResp :: StandardEncode TriggerOTPResp where standardEncode (TriggerOTPResp id) = standardEncode id
instance showTriggerOTPResp :: Show TriggerOTPResp where show = genericShow
instance decodeTriggerOTPResp :: Decode TriggerOTPResp where decode = defaultDecode
instance encodeTriggerOTPResp :: Encode TriggerOTPResp where encode = defaultEncode

derive instance genericTriggerOTPReq :: Generic TriggerOTPReq _
derive instance newtypeTriggerOTPReq :: Newtype TriggerOTPReq _
instance standardEncodeTriggerOTPReq :: StandardEncode TriggerOTPReq where standardEncode (TriggerOTPReq reqBody) = standardEncode reqBody
instance showTriggerOTPReq :: Show TriggerOTPReq where show = genericShow
instance decodeTriggerOTPReq :: Decode TriggerOTPReq where decode = defaultDecode
instance encodeTriggerOTPReq :: Encode TriggerOTPReq where encode = defaultEncode

-------------------------------------------------- Resend OTP API Types --------------------------------------------

newtype ResendOTPResp = ResendOTPResp {
    authId :: String
  , attempts :: Int
}

data ResendOTPRequest = ResendOTPRequest String

instance makeResendOTPRequest :: RestEndpoint ResendOTPRequest ResendOTPResp where
 makeRequest reqBody@(ResendOTPRequest authId) headers = defaultMakeRequest POST (EP.resendOTP authId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericResendOTPResp :: Generic ResendOTPResp _
derive instance newtypeResendOTPResp :: Newtype ResendOTPResp _
instance standardEncodeResendOTPResp :: StandardEncode ResendOTPResp where standardEncode (ResendOTPResp id) = standardEncode id
instance showResendOTPResp :: Show ResendOTPResp where show = genericShow
instance decodeResendOTPResp :: Decode ResendOTPResp where decode = defaultDecode
instance encodeResendOTPResp :: Encode ResendOTPResp where encode = defaultEncode

derive instance genericResendOTPRequest :: Generic ResendOTPRequest _
instance standardEncodeResendOTPRequest :: StandardEncode ResendOTPRequest where standardEncode (ResendOTPRequest authId) = standardEncode authId
instance decodeResendOTPRequest :: Decode ResendOTPRequest where decode = defaultDecode
instance encodeResendOTPRequest :: Encode ResendOTPRequest where encode = defaultEncode

-------------------------------------------------- Verify OTP API Types --------------------------------------------
newtype VerifyTokenResp = VerifyTokenResp {
    token :: String
  , person :: User
}

data WhatsappOptMethods = OPT_IN | OPT_OUT
data VerifyTokenRequest = VerifyTokenRequest String VerifyTokenReq

newtype VerifyTokenReq = VerifyTokenReq { -- Need to check the type for the app
    otp :: String
  , deviceToken :: String
  , whatsappNotificationEnroll :: WhatsappOptMethods
}

newtype User = User { 
    maskedDeviceToken :: Maybe String
  , firstName :: Maybe String
  , middleName :: Maybe String
  , id :: String
  , lastName :: Maybe String
  , maskedMobileNumber :: Maybe String
  }

instance makeVerifyTokenReq :: RestEndpoint VerifyTokenRequest VerifyTokenResp where
 makeRequest reqBody@(VerifyTokenRequest token (VerifyTokenReq rqBody)) headers = defaultMakeRequest POST (EP.verifyToken token) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericWhatsappOptMethods :: Generic WhatsappOptMethods _
instance showWhatsappOptMethods :: Show WhatsappOptMethods where show = genericShow
instance decodeWhatsappOptMethods :: Decode WhatsappOptMethods where decode = defaultDecode
instance encodeWhatsappOptMethods :: Encode WhatsappOptMethods where encode = defaultEncode
instance standardEncodeWhatsappOptMethods :: StandardEncode WhatsappOptMethods 
  where
  standardEncode OPT_IN = standardEncode $ show OPT_IN
  standardEncode OPT_OUT = standardEncode $ show OPT_OUT

derive instance genericVerifyTokenResp :: Generic VerifyTokenResp _
derive instance newtypeVerifyTokenResp :: Newtype VerifyTokenResp _
instance standardEncodeVerifyTokenResp :: StandardEncode VerifyTokenResp where standardEncode (VerifyTokenResp id) = standardEncode id
instance showVerifyTokenResp :: Show VerifyTokenResp where show = genericShow
instance decodeVerifyTokenResp :: Decode VerifyTokenResp where decode = defaultDecode
instance encodeVerifyTokenResp :: Encode VerifyTokenResp where encode = defaultEncode

derive instance genericVerifyTokenReq :: Generic VerifyTokenReq _
derive instance newtypeVerifyTokenReq :: Newtype VerifyTokenReq _
instance standardEncodeVerifyTokenReq :: StandardEncode VerifyTokenReq where standardEncode (VerifyTokenReq reqBody) = standardEncode reqBody -- FOR REVIEW
instance showVerifyTokenReq :: Show VerifyTokenReq where show = genericShow
instance decodeVerifyTokenReq :: Decode VerifyTokenReq where decode = defaultDecode
instance encodeVerifyTokenReq :: Encode VerifyTokenReq where encode = defaultEncode

derive instance genericVerifyTokenRequest :: Generic VerifyTokenRequest _
instance standardEncodeVerifyTokenRequest :: StandardEncode VerifyTokenRequest where standardEncode (VerifyTokenRequest token reqBody) = standardEncode reqBody
instance decodeVerifyTokenRequest :: Decode VerifyTokenRequest where decode = defaultDecode
instance encodeVerifyTokenRequest :: Encode VerifyTokenRequest where encode = defaultEncode

derive instance genericUser :: Generic User _
derive instance newtypeUser :: Newtype User _
instance standardEncodeUser :: StandardEncode User where standardEncode (User req) = standardEncode req
instance showUser :: Show User where show = genericShow
instance decodeUser :: Decode User where decode = defaultDecode
instance encodeUser :: Encode User where encode = defaultEncode

-------------------------------------------------- Logout API Types --------------------------------------------
data LogOutReq = LogOutReq

newtype LogOutRes = LogOutRes {
result :: String
}
instance makeLogOutReq  :: RestEndpoint LogOutReq LogOutRes where
 makeRequest reqBody headers = defaultMakeRequest POST (EP.logout "") headers reqBody
 decodeResponse body = defaultDecodeResponse body
 encodeRequest req = standardEncode req

derive instance genericLogOutReq :: Generic LogOutReq _
instance showLogOutReq :: Show LogOutReq where show = genericShow
instance standardEncodeLogOutReq :: StandardEncode LogOutReq where standardEncode (LogOutReq) = standardEncode {}
instance decodeLogOutReq :: Decode LogOutReq where decode = defaultDecode
instance encodeLogOutReq :: Encode LogOutReq where encode = defaultEncode

derive instance genericLogOutRes :: Generic LogOutRes _
derive instance newtypeLogOutRes :: Newtype LogOutRes _
instance standardEncodeLogOutRes :: StandardEncode LogOutRes where standardEncode (LogOutRes id) = standardEncode id
instance showLogOutRes :: Show LogOutRes where show = genericShow
instance decodeLogOutRes :: Decode LogOutRes where decode = defaultDecode
instance encodeLogOutRes :: Encode LogOutRes where encode = defaultEncode

-------------------------------------------------- Search Location API Types --------------------------------------------

newtype SearchLocationReq = SearchLocationReq {
  components :: String,
  sessionToken :: Maybe String,
  location :: String,
  radius :: Int,
  input :: String,
  language :: String
}

newtype SearchLocationResp = SearchLocationResp {
 predictions:: Array Prediction
}

newtype Prediction = Prediction {
 description :: String,
 placeId :: Maybe String
}

instance makeSearchLocationReq :: RestEndpoint SearchLocationReq SearchLocationResp where
  makeRequest reqBody headers = defaultMakeRequest POST (EP.autoComplete "") headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericSearchLocationReq :: Generic SearchLocationReq _
derive instance newtypeSearchLocationReq :: Newtype SearchLocationReq _
instance standardEncodeSearchLocationReq :: StandardEncode SearchLocationReq where standardEncode (SearchLocationReq payload) = standardEncode payload
instance showSearchLocationReq :: Show SearchLocationReq where show = genericShow
instance decodeSearchLocationReq :: Decode SearchLocationReq where decode = defaultDecode
instance encodeSearchLocationReq :: Encode SearchLocationReq where encode = defaultEncode

derive instance genericSearchLocationResp :: Generic SearchLocationResp _
derive instance newtypeSearchLocationResp :: Newtype SearchLocationResp _
instance standardEncodeSearchLocationResp :: StandardEncode SearchLocationResp where standardEncode (SearchLocationResp id) = standardEncode id
instance showSearchLocationResp :: Show SearchLocationResp where show = genericShow
instance decodeSearchLocationResp :: Decode SearchLocationResp where decode = defaultDecode
instance encodeSearchLocationResp :: Encode SearchLocationResp where encode = defaultEncode

derive instance genericPrediction :: Generic Prediction _
derive instance newtypePrediction :: Newtype Prediction _
instance standardEncodePrediction :: StandardEncode Prediction where standardEncode (Prediction id) = standardEncode id
instance showPrediction :: Show Prediction where show = genericShow
instance decodePrediction :: Decode Prediction where decode = defaultDecode
instance encodePrediction :: Encode Prediction where encode = defaultEncode

-------------------------------------------------- Place Details, Get Cooridnates and Place Name API Types --------------------------------------------

data PlaceDetailsReq = PlaceDetailsReq String

-- data GetCoordinatesReq = GetCoordinatesReq String String

newtype PlaceDetailsResp = PlaceDetailsResp {
 status :: String,
 result :: { geometry :: Geometry}
}

-- newtype GetCoordinatesResp = GetCoordinatesResp {
--  status :: String,
--  results :: Array AddressGeometry
-- }

newtype AddressGeometry = AddressGeometry {
  geometry :: Geometry
}

newtype Geometry = Geometry {
 location :: LocationS
}

newtype LocationS = LocationS {
 lat :: Number,
 lng :: Number
}

newtype PlaceName = PlaceName {
 formattedAddress :: String,
 location :: LatLong,
 plusCode :: Maybe String,
 addressComponents :: Array AddressComponents
}

newtype AddressComponents =  AddressComponents {
  longName :: String ,
  shortName :: String,
  types :: Array String
}

derive instance genericAddressComponents :: Generic AddressComponents _
derive instance newtypeAddressComponents :: Newtype AddressComponents _
instance standardEncodeAddressComponents :: StandardEncode AddressComponents where standardEncode (AddressComponents payload) = standardEncode payload
instance showAddressComponents :: Show AddressComponents where show = genericShow
instance decodeAddressComponents :: Decode AddressComponents where decode = defaultDecode
instance encodeAddressComponents :: Encode AddressComponents where encode = defaultEncode

newtype GetPlaceNameReq = GetPlaceNameReq {
  sessionToken :: Maybe String,
  language :: Maybe String,
  getBy :: GetPlaceNameBy
}


newtype GetPlaceNameBy = GetPlaceNameBy {
  tag :: String,
  contents :: Contents
}

data Contents = PlaceId String | LatLongType LatLonBody

derive instance genericContents :: Generic Contents _
instance showContents :: Show Contents where show = genericShow
instance decodeContents :: Decode Contents where decode = defaultDecode
instance encodeContents :: Encode Contents where encode = defaultEncode
instance standardEncodeContents :: StandardEncode Contents
  where
    standardEncode (LatLongType body) = standardEncode body
    standardEncode (PlaceId param) = standardEncode param

type PlaceId = String

newtype LatLonBody = LatLonBody 
  { lat :: Number
  , lon :: Number
  }


derive instance genericLatLonBody :: Generic LatLonBody _
derive instance newtypeLatLonBody :: Newtype LatLonBody _
instance standardEncodeLatLonBody :: StandardEncode LatLonBody where standardEncode (LatLonBody payload) = standardEncode payload
instance showLatLonBody :: Show LatLonBody where show = genericShow
instance decodeLatLonBody :: Decode LatLonBody where decode = defaultDecode
instance encodeLatLonBody :: Encode LatLonBody where encode = defaultEncode

newtype GetPlaceNameResp = GetPlaceNameResp (Array PlaceName)


instance placeDetailsReq :: RestEndpoint PlaceDetailsReq PlaceDetailsResp where
 makeRequest reqBody@(PlaceDetailsReq id) headers = defaultMakeRequest GET (EP.placeDetails id) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

-- instance getCoordinatesReq :: RestEndpoint GetCoordinatesReq GetCoordinatesResp where
--  makeRequest reqBody@(GetCoordinatesReq id language) headers = defaultMakeRequest GET (EP.getCoordinates id language) headers reqBody
--  decodeResponse = decodeJSON
--  encodeRequest req = standardEncode req

instance makeGetPlaceNameReq :: RestEndpoint GetPlaceNameReq GetPlaceNameResp where
 makeRequest reqBody@(GetPlaceNameReq payload) headers = defaultMakeRequest POST (EP.getPlaceName "") headers reqBody
 decodeResponse body = defaultDecodeResponse body
 encodeRequest req = standardEncode req

derive instance genericGetPlaceNameReq :: Generic GetPlaceNameReq _
derive instance newtypeGetPlaceNameReq :: Newtype GetPlaceNameReq _
instance standardEncodeGetPlaceNameReq :: StandardEncode GetPlaceNameReq where standardEncode (GetPlaceNameReq payload) = standardEncode payload
instance showGetPlaceNameReq :: Show GetPlaceNameReq where show = genericShow
instance decodeGetPlaceNameReq :: Decode GetPlaceNameReq where decode = defaultDecode
instance encodeGetPlaceNameReq :: Encode GetPlaceNameReq where encode = defaultEncode

derive instance genericGetPlaceNameBy :: Generic GetPlaceNameBy _
derive instance newtypeGetPlaceNameBy :: Newtype GetPlaceNameBy _
instance standardEncodeGetPlaceNameBy :: StandardEncode GetPlaceNameBy where standardEncode (GetPlaceNameBy body) = standardEncode body
instance showGetPlaceNameBy :: Show GetPlaceNameBy where show = genericShow
instance decodeGetPlaceNameBy :: Decode GetPlaceNameBy where decode = defaultDecode
instance encodeGetPlaceNameBy :: Encode GetPlaceNameBy where encode = defaultEncode

derive instance genericGetPlaceNameResp :: Generic GetPlaceNameResp _
derive instance newtypeGetPlaceNameResp :: Newtype GetPlaceNameResp _
instance standardEncodeGetPlaceNameResp :: StandardEncode GetPlaceNameResp where standardEncode (GetPlaceNameResp body) = standardEncode body
instance showGetPlaceNameResp :: Show GetPlaceNameResp where show = genericShow
instance decodeGetPlaceNameResp :: Decode GetPlaceNameResp where decode = defaultDecode
instance encodeGetPlaceNameResp :: Encode GetPlaceNameResp where encode = defaultEncode

derive instance genericPlaceName :: Generic PlaceName _
derive instance newtypePlaceName :: Newtype PlaceName _
instance standardEncodePlaceName :: StandardEncode PlaceName where standardEncode (PlaceName body) = standardEncode body
instance showPlaceName :: Show PlaceName where show = genericShow
instance decodePlaceName :: Decode PlaceName where decode = defaultDecode
instance encodePlaceName :: Encode PlaceName where encode = defaultEncode

derive instance genericAddressGeometry :: Generic AddressGeometry _
derive instance newtypeAddressGeometry :: Newtype AddressGeometry _
instance standardEncodeAddressGeometry :: StandardEncode AddressGeometry where standardEncode (AddressGeometry body) = standardEncode body
instance showAddressGeometry :: Show AddressGeometry where show = genericShow
instance decodeAddressGeometry :: Decode AddressGeometry where decode = defaultDecode
instance encodeAddressGeometry :: Encode AddressGeometry where encode = defaultEncode

derive instance genericPlaceDetailsReq :: Generic PlaceDetailsReq _
instance standardEncodePlaceDetailsReq :: StandardEncode PlaceDetailsReq where standardEncode (PlaceDetailsReq id) = standardEncode id
instance showPlaceDetailsReq :: Show PlaceDetailsReq where show = genericShow
instance decodePlaceDetailsReq :: Decode PlaceDetailsReq where decode = defaultDecode
instance encodePlaceDetailsReq :: Encode PlaceDetailsReq where encode = defaultEncode

-- derive instance genericGetCoordinatesReq :: Generic GetCoordinatesReq _
-- instance standardEncodeGetCoordinatesReq :: StandardEncode GetCoordinatesReq where standardEncode (GetCoordinatesReq id language) = standardEncode id
-- instance showGetCoordinatesReq :: Show GetCoordinatesReq where show = genericShow
-- instance decodeGetCoordinatesReq :: Decode GetCoordinatesReq where decode = defaultDecode
-- instance encodeGetCoordinatesReq :: Encode GetCoordinatesReq where encode = defaultEncode

-- derive instance genericGetCoordinatesResp :: Generic GetCoordinatesResp _
-- derive instance newtypeGetCoordinatesResp :: Newtype GetCoordinatesResp _
-- instance standardEncodeGetCoordinatesResp :: StandardEncode GetCoordinatesResp where standardEncode (GetCoordinatesResp reqBody) = standardEncode reqBody
-- instance decodeGetCoordinatesResp :: Decode GetCoordinatesResp where decode = defaultDecode
-- instance encodeGetCoordinatesResp :: Encode GetCoordinatesResp where encode = defaultEncode

derive instance genericPlaceDetailsResp :: Generic PlaceDetailsResp _
derive instance newtypePlaceDetailsResp :: Newtype PlaceDetailsResp _
instance standardEncodePlaceDetailsResp :: StandardEncode PlaceDetailsResp where standardEncode (PlaceDetailsResp reqBody) = standardEncode reqBody
instance decodePlaceDetailsResp :: Decode PlaceDetailsResp where decode = defaultDecode
instance encodePlaceDetailsResp :: Encode PlaceDetailsResp where encode = defaultEncode

derive instance genericLocationS :: Generic LocationS _
derive instance newtypeLocationS :: Newtype LocationS _
instance standardEncodeLocationS :: StandardEncode LocationS where standardEncode (LocationS req) = standardEncode req
instance showLocationS :: Show LocationS where show = genericShow
instance decodeLocationS :: Decode LocationS where decode = defaultDecode
instance encodeLocationS :: Encode LocationS where encode = defaultEncode

derive instance genericGeometry :: Generic Geometry _
derive instance newtypeGeometry :: Newtype Geometry _
instance standardEncodeGeometry :: StandardEncode Geometry where standardEncode (Geometry req) = standardEncode req
instance showGeometry :: Show Geometry where show = genericShow
instance decodeGeometry :: Decode Geometry where decode = defaultDecode
instance encodeGeometry :: Encode Geometry where encode = defaultEncode

-------- For RideSearch -----------

newtype SearchReq = SearchReq {
  contents :: OneWaySearchReq ,
  fareProductType :: String
}

newtype OneWaySearchReq = OneWaySearchReq {
  origin :: SearchReqLocation,
  destination :: SearchReqLocation
}

newtype SearchReqLocation = SearchReqLocation { 
    gps :: LatLong 
  , address :: LocationAddress
  }
  
newtype LatLong = LatLong {
  lat :: Number,
  lon :: Number 
}

newtype SearchRes = SearchRes {
  searchId :: String, 
  routeInfo :: Maybe Route
}

newtype LocationAddress = LocationAddress {
  area :: Maybe String,
  state :: Maybe String,
  country :: Maybe String,
  building :: Maybe String,
  door :: Maybe String,
  street :: Maybe String,
  city :: Maybe String,
  areaCode :: Maybe String,
  ward :: Maybe String,
  placeId :: Maybe String
}
derive instance genericLocationAddress :: Generic LocationAddress _
derive instance newtypeLocationAddress :: Newtype LocationAddress _
instance standardEncodeLocationAddress :: StandardEncode LocationAddress where standardEncode (LocationAddress body) = standardEncode body
instance showLocationAddress :: Show LocationAddress where show = genericShow
instance decodeLocationAddress :: Decode LocationAddress where decode = defaultDecode
instance encodeLocationAddress  :: Encode LocationAddress where encode = defaultEncode

instance makeSearchReq :: RestEndpoint SearchReq SearchRes where
 makeRequest reqBody headers = defaultMakeRequest POST (EP.searchReq "") headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericSearchReq :: Generic SearchReq _
derive instance newtypeSearchReq :: Newtype SearchReq _
instance standardEncodeSearchReq :: StandardEncode SearchReq where standardEncode (SearchReq body) = standardEncode body
instance showSearchReq :: Show SearchReq where show = genericShow
instance decodeSearchReq :: Decode SearchReq where decode = defaultDecode
instance encodeSearchReq:: Encode SearchReq where encode = defaultEncode

derive instance genericLatLong :: Generic LatLong _
derive instance newtypeLatLong :: Newtype LatLong _
instance standardEncodeLatLong :: StandardEncode LatLong where standardEncode (LatLong body) = standardEncode body
instance showLatLong :: Show LatLong where show = genericShow
instance decodeLatLong :: Decode LatLong where decode = defaultDecode
instance encodeLatLong:: Encode LatLong where encode = defaultEncode

derive instance genericSearchRes :: Generic SearchRes _
derive instance newtypeSearchRes :: Newtype SearchRes _
instance standardEncodeSearchRes :: StandardEncode SearchRes where standardEncode (SearchRes body) = standardEncode body
instance showSearchRes :: Show SearchRes where show = genericShow
instance decodeSearchRes :: Decode SearchRes where decode = defaultDecode
instance encodeSearchRes :: Encode SearchRes where encode = defaultEncode

derive instance genericSearchReqLocation :: Generic SearchReqLocation _
derive instance newtypeSearchReqLocation :: Newtype SearchReqLocation _
instance standardEncodeSearchReqLocation :: StandardEncode SearchReqLocation where standardEncode (SearchReqLocation body) = standardEncode body
instance showSearchReqLocation :: Show SearchReqLocation where show = genericShow
instance decodeSearchReqLocation :: Decode SearchReqLocation where decode = defaultDecode
instance encodeSearchReqLocation :: Encode SearchReqLocation where encode = defaultEncode

derive instance genericOneWaySearchReq :: Generic OneWaySearchReq _
derive instance newtypeOneWaySearchReq :: Newtype OneWaySearchReq _
instance standardEncodeOneWaySearchReq :: StandardEncode OneWaySearchReq where standardEncode (OneWaySearchReq body) = standardEncode body
instance showOneWaySearchReq :: Show OneWaySearchReq where show = genericShow
instance decodeOneWaySearchReq :: Decode OneWaySearchReq where decode = defaultDecode
instance encodeOneWaySearchReq :: Encode OneWaySearchReq where encode = defaultEncode

----- For rideSearch/{searchId}/results 

data GetQuotesReq = GetQuotesReq String

newtype GetQuotesRes = GetQuotesRes {
  quotes :: Array OfferRes,
  estimates :: Array EstimateAPIEntity,
  fromLocation :: SearchReqLocationAPIEntity,
  toLocation :: Maybe SearchReqLocationAPIEntity
}

newtype EstimateAPIEntity = EstimateAPIEntity {
  agencyNumber :: String,
  createdAt :: String,
  discount :: Maybe Int,
  estimatedTotalFare :: Int,
  agencyName :: String,
  vehicleVariant :: String,
  estimatedFare :: Int,
  tripTerms :: Array String,
  id :: String,
  agencyCompletedRidesCount :: Int,
  estimateFareBreakup :: Maybe (Array EstimateFares),
  totalFareRange :: Maybe FareRange,
  nightShiftRate :: Maybe NightShiftRate
}

newtype NightShiftRate = NightShiftRate {
  nightShiftEnd :: Maybe String,
  nightShiftMultiplier :: Maybe Number,
  nightShiftStart :: Maybe String 
}

newtype FareRange = FareRange {
  maxFare :: Int,
  minFare :: Int
}

newtype EstimateFares = EstimateFares {
  price :: Int,
  title :: String
}

newtype SearchReqLocationAPIEntity = SearchReqLocationAPIEntity {
  lat :: Number,
  lon :: Number
}

newtype OfferRes = OfferRes {
  onDemandCab :: QuoteAPIEntity,
  metro ::  MetroOffer,
  publicTransport :: PublicTransportQuote
}

newtype QuoteAPIEntity = QuoteAPIEntity {
  agencyNumber :: String,
  createdAt :: String,
  discount :: Maybe Int,
  estimatedTotalFare :: Int,
  agencyName :: String,
  quoteDetails :: QuoteAPIDetails,
  vehicleVariant :: String,
  estimatedFare :: Int,
  tripTerms :: Array String,
  id :: String,
  agencyCompletedRidesCount :: Int
}

newtype QuoteAPIDetails = QuoteAPIDetails {
  contents :: DriverOfferAPIEntity,
  fareProductType :: String
}

newtype DriverOfferAPIEntity = DriverOfferAPIEntity 
  {
    rating :: Maybe Number
  , validTill :: String
  , driverName :: String
  , distanceToPickup :: Number
  , durationToPickup :: Int
  }

newtype MetroOffer = MetroOffer {
  createdAt :: String,
  description :: String,
  rides :: Array MetroRide,
  rideSearchId :: String
}

newtype MetroRide = MetroRide {
  schedule :: Array Schedule,
  price :: Int,
  departureStation :: MetroStation,
  arrivalStation :: MetroStation
}

newtype Schedule = Schedule {
  arrivalTime :: String,
  departureTime :: String
}

newtype MetroStation = MetroStation {
  stationCode :: String,
  point :: LatLong,
  name :: String
}

newtype PublicTransportQuote = PublicTransportQuote {
  createdAt :: String,
  fare :: Int,
  arrivalTime :: String,
  id :: String,
  departureStation :: PublicTransportStation,
  description :: String,
  departureTime :: String,
  arrivalStation :: PublicTransportStation
}

newtype PublicTransportStation = PublicTransportStation {
  stationCode :: String,
  lat :: Number,
  lon :: Number,
  name :: String
}

instance makeGetQuotesReq :: RestEndpoint GetQuotesReq GetQuotesRes where
 makeRequest reqBody@(GetQuotesReq searchId) headers = defaultMakeRequest GET (EP.getQuotes searchId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericGetQuotesRes :: Generic GetQuotesRes _
derive instance newtypeGetQuotesRes :: Newtype GetQuotesRes _
instance standardEncodeGetQuotesRes :: StandardEncode GetQuotesRes where standardEncode (GetQuotesRes body) = standardEncode body
instance showGetQuotesRes :: Show GetQuotesRes where show = genericShow
instance decodeGetQuotesRes :: Decode GetQuotesRes where decode = defaultDecode
instance encodeGetQuotesRes  :: Encode GetQuotesRes where encode = defaultEncode

derive instance genericGetQuotesReq :: Generic GetQuotesReq _
instance standardEncodeGetQuotesReq :: StandardEncode GetQuotesReq where standardEncode (GetQuotesReq body) = standardEncode body
instance showGetQuotesReq :: Show GetQuotesReq where show = genericShow
instance decodeGetQuotesReq :: Decode GetQuotesReq where decode = defaultDecode
instance encodeGetQuotesReq  :: Encode GetQuotesReq where encode = defaultEncode

derive instance genericEstimateAPIEntity :: Generic EstimateAPIEntity _
derive instance newtypeEstimateAPIEntity :: Newtype EstimateAPIEntity _
instance standardEncodeEstimateAPIEntity :: StandardEncode EstimateAPIEntity where standardEncode (EstimateAPIEntity body) = standardEncode body
instance showEstimateAPIEntity :: Show EstimateAPIEntity where show = genericShow
instance decodeEstimateAPIEntity :: Decode EstimateAPIEntity where decode = defaultDecode
instance encodeEstimateAPIEntity  :: Encode EstimateAPIEntity where encode = defaultEncode

derive instance genericEstimateFares :: Generic EstimateFares _
derive instance newtypeEstimateFares :: Newtype EstimateFares _
instance standardEncodeEstimateFares :: StandardEncode EstimateFares where standardEncode (EstimateFares body) = standardEncode body
instance showEstimateFares :: Show EstimateFares where show = genericShow
instance decodeEstimateFares :: Decode EstimateFares where decode = defaultDecode
instance encodeEstimateFares  :: Encode EstimateFares where encode = defaultEncode

derive instance genericFareRange :: Generic FareRange _
derive instance newtypeFareRange :: Newtype FareRange _
instance standardEncodeFareRange :: StandardEncode FareRange where standardEncode (FareRange body) = standardEncode body
instance showFareRange :: Show FareRange where show = genericShow
instance decodeFareRange :: Decode FareRange where decode = defaultDecode
instance encodeFareRange  :: Encode FareRange where encode = defaultEncode

derive instance genericNightShiftRate :: Generic NightShiftRate _
derive instance newtypeNightShiftRate :: Newtype NightShiftRate _
instance standardEncodeNightShiftRate :: StandardEncode NightShiftRate where standardEncode (NightShiftRate body) = standardEncode body
instance showNightShiftRate :: Show NightShiftRate where show = genericShow
instance decodeNightShiftRate :: Decode NightShiftRate where decode = defaultDecode
instance encodeNightShiftRate  :: Encode NightShiftRate where encode = defaultEncode

derive instance genericSearchReqLocationAPIEntity :: Generic SearchReqLocationAPIEntity _
derive instance newtypeSearchReqLocationAPIEntity :: Newtype SearchReqLocationAPIEntity _
instance standardEncodeSearchReqLocationAPIEntity :: StandardEncode SearchReqLocationAPIEntity where standardEncode (SearchReqLocationAPIEntity body) = standardEncode body
instance showSearchReqLocationAPIEntity :: Show SearchReqLocationAPIEntity where show = genericShow
instance decodeSearchReqLocationAPIEntity :: Decode SearchReqLocationAPIEntity where decode = defaultDecode
instance encodeSearchReqLocationAPIEntity  :: Encode SearchReqLocationAPIEntity where encode = defaultEncode

derive instance genericOfferRes :: Generic OfferRes _
derive instance newtypeOfferRes :: Newtype OfferRes _
instance standardEncodeOfferRes :: StandardEncode OfferRes where standardEncode (OfferRes body) = standardEncode body
instance showOfferRes :: Show OfferRes where show = genericShow
instance decodeOfferRes :: Decode OfferRes where decode = defaultDecode
instance encodeOfferRes  :: Encode OfferRes where encode = defaultEncode

derive instance genericQuoteAPIEntity :: Generic QuoteAPIEntity _
derive instance newtypeQuoteAPIEntity :: Newtype QuoteAPIEntity _
instance standardEncodeQuoteAPIEntity :: StandardEncode QuoteAPIEntity where standardEncode (QuoteAPIEntity body) = standardEncode body
instance showQuoteAPIEntity :: Show QuoteAPIEntity where show = genericShow
instance decodeQuoteAPIEntity :: Decode QuoteAPIEntity where decode = defaultDecode
instance encodeQuoteAPIEntity  :: Encode QuoteAPIEntity where encode = defaultEncode

derive instance genericQuoteAPIDetails :: Generic QuoteAPIDetails _
derive instance newtypeQuoteAPIDetails :: Newtype QuoteAPIDetails _
instance standardEncodeQuoteAPIDetails :: StandardEncode QuoteAPIDetails where standardEncode (QuoteAPIDetails body) = standardEncode body
instance showQuoteAPIDetails :: Show QuoteAPIDetails where show = genericShow
instance decodeQuoteAPIDetails :: Decode QuoteAPIDetails where decode = defaultDecode
instance encodeQuoteAPIDetails  :: Encode QuoteAPIDetails where encode = defaultEncode

derive instance genericDriverOfferAPIEntity :: Generic DriverOfferAPIEntity _
derive instance newtypeDriverOfferAPIEntity :: Newtype DriverOfferAPIEntity _
instance standardEncodeDriverOfferAPIEntity :: StandardEncode DriverOfferAPIEntity where standardEncode (DriverOfferAPIEntity body) = standardEncode body
instance showDriverOfferAPIEntity :: Show DriverOfferAPIEntity where show = genericShow
instance decodeDriverOfferAPIEntity :: Decode DriverOfferAPIEntity where decode = defaultDecode
instance encodeDriverOfferAPIEntity  :: Encode DriverOfferAPIEntity where encode = defaultEncode

derive instance genericMetroOffer :: Generic MetroOffer _
derive instance newtypeMetroOffer :: Newtype MetroOffer _
instance standardEncodeMetroOffer :: StandardEncode MetroOffer where standardEncode (MetroOffer body) = standardEncode body
instance showMetroOffer :: Show MetroOffer where show = genericShow
instance decodeMetroOffer :: Decode MetroOffer where decode = defaultDecode
instance encodeMetroOffer  :: Encode MetroOffer where encode = defaultEncode

derive instance genericMetroRide :: Generic MetroRide _
derive instance newtypeMetroRide :: Newtype MetroRide _
instance standardEncodeMetroRide :: StandardEncode MetroRide where standardEncode (MetroRide body) = standardEncode body
instance showMetroRide :: Show MetroRide where show = genericShow
instance decodeMetroRide :: Decode MetroRide where decode = defaultDecode
instance encodeMetroRide  :: Encode MetroRide where encode = defaultEncode

derive instance genericSchedule :: Generic Schedule _
derive instance newtypeSchedule :: Newtype Schedule _
instance standardEncodeSchedule :: StandardEncode Schedule where standardEncode (Schedule body) = standardEncode body
instance showSchedule :: Show Schedule where show = genericShow
instance decodeSchedule :: Decode Schedule where decode = defaultDecode
instance encodeSchedule  :: Encode Schedule where encode = defaultEncode

derive instance genericMetroStation :: Generic MetroStation _
derive instance newtypeMetroStation :: Newtype MetroStation _
instance standardEncodeMetroStation :: StandardEncode MetroStation where standardEncode (MetroStation body) = standardEncode body
instance showMetroStation :: Show MetroStation where show = genericShow
instance decodeMetroStation :: Decode MetroStation where decode = defaultDecode
instance encodeMetroStation  :: Encode MetroStation where encode = defaultEncode

derive instance genericPublicTransportQuote :: Generic PublicTransportQuote _
derive instance newtypePublicTransportQuote :: Newtype PublicTransportQuote _
instance standardEncodePublicTransportQuote :: StandardEncode PublicTransportQuote where standardEncode (PublicTransportQuote body) = standardEncode body
instance showPublicTransportQuote :: Show PublicTransportQuote where show = genericShow
instance decodePublicTransportQuote :: Decode PublicTransportQuote where decode = defaultDecode
instance encodePublicTransportQuote  :: Encode PublicTransportQuote where encode = defaultEncode

derive instance genericPublicTransportStation :: Generic PublicTransportStation _
derive instance newtypePublicTransportStation :: Newtype PublicTransportStation _
instance standardEncodePublicTransportStation :: StandardEncode PublicTransportStation where standardEncode (PublicTransportStation body) = standardEncode body
instance showPublicTransportStation :: Show PublicTransportStation where show = genericShow
instance decodePublicTransportStation :: Decode PublicTransportStation where decode = defaultDecode
instance encodePublicTransportStation  :: Encode PublicTransportStation where encode = defaultEncode


----- For rideSearch/quotes/{quoteId}/confirm

data ConfirmRequest = ConfirmRequest String


newtype ConfirmRes = ConfirmRes {
  bookingId :: String 
}

instance makeConfirmRequest :: RestEndpoint ConfirmRequest ConfirmRes where
 makeRequest reqBody@(ConfirmRequest quoteId) headers = defaultMakeRequest POST (EP.confirmRide quoteId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericConfirmRes :: Generic ConfirmRes _
derive instance newtypeConfirmRes :: Newtype ConfirmRes _
instance standardEncodeConfirmRes :: StandardEncode ConfirmRes where standardEncode (ConfirmRes body) = standardEncode body
instance showConfirmRes :: Show ConfirmRes where show = genericShow
instance decodeConfirmRes :: Decode ConfirmRes where decode = defaultDecode
instance encodeConfirmRes  :: Encode ConfirmRes where encode = defaultEncode

derive instance genericConfirmRequest :: Generic ConfirmRequest _
instance standardEncodeConfirmRequest :: StandardEncode ConfirmRequest where standardEncode (ConfirmRequest quoteId) = standardEncode quoteId
instance showConfirmRequest :: Show ConfirmRequest where show = genericShow
instance decodeConfirmRequest :: Decode ConfirmRequest where decode = defaultDecode
instance encodeConfirmRequest  :: Encode ConfirmRequest where encode = defaultEncode

------- rideBooking/{bookingId}

data RideBookingReq = RideBookingReq String

newtype RideBookingRes = RideBookingRes {
  agencyNumber :: String,
  status :: String,
  rideStartTime :: Maybe String,
  rideEndTime :: Maybe String,
  duration :: Maybe Int,
  fareBreakup :: Array FareBreakupAPIEntity,
  createdAt :: String,
  discount :: Maybe Int,
  estimatedTotalFare :: Int,
  agencyName :: String,
  rideList :: Array RideAPIEntity,
  estimatedFare :: Int,
  tripTerms :: Array String,
  id :: String,
  updatedAt :: String,
  bookingDetails :: RideBookingAPIDetails ,
  fromLocation ::  BookingLocationAPIEntity
}

newtype FareBreakupAPIEntity = FareBreakupAPIEntity {
  amount :: Number,
  description :: String
}

newtype RideAPIEntity = RideAPIEntity {
  computedPrice :: Maybe Int,
  status :: String,
  vehicleModel :: String,
  createdAt :: String,
  driverNumber :: String,
  shortRideId :: String,
  driverRegisteredAt :: String,
  vehicleNumber :: String,
  rideOtp :: String,
  driverName :: String,
  chargeableRideDistance :: Maybe Number,
  vehicleVariant :: String,
  driverRatings :: Maybe Number,
  vehicleColor :: String,
  id :: String,
  updatedAt :: String,
  rideStartTime :: Maybe String,
  rideEndTime:: Maybe String,
  rideRating :: Maybe Int,
  driverArrivalTime :: Maybe String,
  bppRideId :: String
}

newtype RideBookingAPIDetails = RideBookingAPIDetails {
  contents :: RideBookingDetails,
  fareProductType :: String
}

newtype RideBookingDetails = RideBookingDetails {
  toLocation :: BookingLocationAPIEntity,
  estimatedDistance :: Maybe Int
}

newtype BookingLocationAPIEntity = BookingLocationAPIEntity {
  area :: Maybe String,
  state :: Maybe String,
  country :: Maybe String,
  building :: Maybe String,
  door :: Maybe String,
  street :: Maybe String,
  lat :: Number,
  city :: Maybe String,
  areaCode :: Maybe String,
  lon :: Number,
  ward :: Maybe String,
  placeId :: Maybe String
}

instance makeRideBooking :: RestEndpoint RideBookingReq RideBookingRes where
 makeRequest reqBody@(RideBookingReq bookingId) headers = defaultMakeRequest POST (EP.ridebooking bookingId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericRideBookingReq :: Generic RideBookingReq _
instance standardEncodeRideBookingReq :: StandardEncode RideBookingReq where standardEncode (RideBookingReq body) = standardEncode body
instance showRideBookingReq :: Show RideBookingReq where show = genericShow
instance decodeRideBookingReq :: Decode RideBookingReq where decode = defaultDecode
instance encodeRideBookingReq  :: Encode RideBookingReq where encode = defaultEncode

derive instance genericRideBookingRes :: Generic RideBookingRes _
derive instance newtypeRideBookingRes :: Newtype RideBookingRes _
instance standardEncodeRideBookingRes :: StandardEncode RideBookingRes where standardEncode (RideBookingRes body) = standardEncode body
instance showRideBookingRes :: Show RideBookingRes where show = genericShow
instance decodeRideBookingRes :: Decode RideBookingRes where decode = defaultDecode
instance encodeRideBookingRes  :: Encode RideBookingRes where encode = defaultEncode

derive instance genericFareBreakupAPIEntity :: Generic FareBreakupAPIEntity _
derive instance newtypeFareBreakupAPIEntity :: Newtype FareBreakupAPIEntity _
instance standardEncodeFareBreakupAPIEntity :: StandardEncode FareBreakupAPIEntity where standardEncode (FareBreakupAPIEntity body) = standardEncode body
instance showFareBreakupAPIEntity :: Show FareBreakupAPIEntity where show = genericShow
instance decodeFareBreakupAPIEntity :: Decode FareBreakupAPIEntity where decode = defaultDecode
instance encodeFareBreakupAPIEntity  :: Encode FareBreakupAPIEntity where encode = defaultEncode

derive instance genericRideAPIEntity :: Generic RideAPIEntity _
derive instance newtypeRideAPIEntity :: Newtype RideAPIEntity _
instance standardEncodeRideAPIEntity :: StandardEncode RideAPIEntity where standardEncode (RideAPIEntity body) = standardEncode body
instance showRideAPIEntity :: Show RideAPIEntity where show = genericShow
instance decodeRideAPIEntity :: Decode RideAPIEntity where decode = defaultDecode
instance encodeRideAPIEntity  :: Encode RideAPIEntity where encode = defaultEncode

derive instance genericRideBookingAPIDetails :: Generic RideBookingAPIDetails _
derive instance newtypeRideBookingAPIDetails :: Newtype RideBookingAPIDetails _
instance standardEncodeRideBookingAPIDetails :: StandardEncode RideBookingAPIDetails where standardEncode (RideBookingAPIDetails body) = standardEncode body
instance showRideBookingAPIDetails :: Show RideBookingAPIDetails where show = genericShow
instance decodeRideBookingAPIDetails :: Decode RideBookingAPIDetails where decode = defaultDecode
instance encodeRideBookingAPIDetails  :: Encode RideBookingAPIDetails where encode = defaultEncode

derive instance genericRideBookingDetails :: Generic RideBookingDetails _
derive instance newtypeRideBookingDetails :: Newtype RideBookingDetails _
instance standardEncodeRideBookingDetails :: StandardEncode RideBookingDetails where standardEncode (RideBookingDetails body) = standardEncode body
instance showRideBookingDetails :: Show RideBookingDetails where show = genericShow
instance decodeRideBookingDetails :: Decode RideBookingDetails where decode = defaultDecode
instance encodeRideBookingDetails  :: Encode RideBookingDetails where encode = defaultEncode

derive instance genericBookingLocationAPIEntity :: Generic BookingLocationAPIEntity _
derive instance newtypeBookingLocationAPIEntity :: Newtype BookingLocationAPIEntity _
instance standardEncodeBookingLocationAPIEntity :: StandardEncode BookingLocationAPIEntity where standardEncode (BookingLocationAPIEntity body) = standardEncode body
instance showBookingLocationAPIEntity :: Show BookingLocationAPIEntity where show = genericShow
instance decodeBookingLocationAPIEntity :: Decode BookingLocationAPIEntity where decode = defaultDecode
instance encodeBookingLocationAPIEntity  :: Encode BookingLocationAPIEntity where encode = defaultEncode

-------------------------------------------------- Select Estimate Id  API Types -----------------------------------------------------------------

data SelectEstimateReq = SelectEstimateReq String DEstimateSelect

newtype DEstimateSelect = DEstimateSelect
  { 
    autoAssignEnabled :: Boolean
  }

newtype SelectEstimateRes = SelectEstimateRes
  {
    result :: String 
  }

instance makeSelectEstimateReq :: RestEndpoint SelectEstimateReq SelectEstimateRes where
 makeRequest reqBody@(SelectEstimateReq estimateId (DEstimateSelect rqBody)) headers = defaultMakeRequest POST (EP.selectEstimate estimateId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericSelectEstimateRes :: Generic SelectEstimateRes _
derive instance newtypeSelectEstimateRes :: Newtype SelectEstimateRes _
instance standardEncodeSelectEstimateRes :: StandardEncode SelectEstimateRes where standardEncode (SelectEstimateRes body) = standardEncode body
instance showSelectEstimateRes :: Show SelectEstimateRes where show = genericShow
instance decodeSelectEstimateRes :: Decode SelectEstimateRes where decode = defaultDecode
instance encodeSelectEstimateRes  :: Encode SelectEstimateRes where encode = defaultEncode   

derive instance genericDEstimateSelect :: Generic DEstimateSelect _
derive instance newtypeDEstimateSelect :: Newtype DEstimateSelect _
instance standardEncodeDEstimateSelect :: StandardEncode DEstimateSelect where standardEncode (DEstimateSelect reqBody) = standardEncode reqBody
instance showDEstimateSelect :: Show DEstimateSelect where show = genericShow
instance decodeDEstimateSelect :: Decode DEstimateSelect where decode = defaultDecode
instance encodeDEstimateSelect :: Encode DEstimateSelect where encode = defaultEncode

derive instance genericSelectEstimateReq :: Generic SelectEstimateReq _
instance standardEncodeSelectEstimateReq :: StandardEncode SelectEstimateReq where standardEncode (SelectEstimateReq estimateId body) = standardEncode body
instance showSelectEstimateReq :: Show SelectEstimateReq where show = genericShow
instance decodeSelectEstimateReq :: Decode SelectEstimateReq where decode = defaultDecode
instance encodeSelectEstimateReq  :: Encode SelectEstimateReq where encode = defaultEncode   

-------------------------------------------------------------------------------Estimated Quotes API Types ------------------------------------------------------------
data SelectListReq = SelectListReq String 

newtype SelectListRes = SelectListRes {
  selectedQuotes :: Array QuoteAPIEntity
}

instance makeSelectListReq :: RestEndpoint SelectListReq SelectListRes where
 makeRequest reqBody@(SelectListReq estimateId) headers = defaultMakeRequest GET (EP.selectList estimateId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericSelectListReq :: Generic SelectListReq _
instance standardEncodeSelectListReq :: StandardEncode SelectListReq where standardEncode (SelectListReq body) = standardEncode body
instance showSelectListReq :: Show SelectListReq where show = genericShow
instance decodeSelectListReq :: Decode SelectListReq where decode = defaultDecode
instance encodeSelectListReq  :: Encode SelectListReq where encode = defaultEncode   

derive instance genericSelectListRes :: Generic SelectListRes _
derive instance newtypeSelectListRes :: Newtype SelectListRes _
instance standardEncodeSelectListRes :: StandardEncode SelectListRes where standardEncode (SelectListRes body) = standardEncode body
instance showSelectListRes :: Show SelectListRes where show = genericShow
instance decodeSelectListRes :: Decode SelectListRes where decode = defaultDecode
instance encodeSelectListRes  :: Encode SelectListRes where encode = defaultEncode   


--- rideBooking/{bookingId}/cancel

data CancelRequest = CancelRequest CancelReq String

newtype CancelReq = CancelReq {
  additionalInfo :: Maybe String,
  reasonCode :: String,
  reasonStage :: String
}

newtype CancelRes = CancelRes {
  result :: String
}

instance makeCancelReq :: RestEndpoint CancelRequest CancelRes where
 makeRequest reqBody@(CancelRequest rqBody bookingId) headers = defaultMakeRequest POST (EP.cancelRide bookingId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericCancelRes :: Generic CancelRes _
derive instance newtypeCancelRes :: Newtype CancelRes _
instance standardEncodeCancelRes :: StandardEncode CancelRes where standardEncode (CancelRes body) = standardEncode body
instance showCancelRes :: Show CancelRes where show = genericShow
instance decodeCancelRes :: Decode CancelRes where decode = defaultDecode
instance encodeCancelRes  :: Encode CancelRes where encode = defaultEncode   

derive instance genericCancelReq :: Generic CancelReq _
derive instance newtypeCancelReq :: Newtype CancelReq _
instance standardEncodeCancelReq :: StandardEncode CancelReq where standardEncode (CancelReq body) = standardEncode body
instance showCancelReq :: Show CancelReq where show = genericShow
instance decodeCancelReq :: Decode CancelReq where decode = defaultDecode
instance encodeCancelReq  :: Encode CancelReq where encode = defaultEncode   

derive instance genericCancelRequest :: Generic CancelRequest _
instance standardEncodeCancelRequest :: StandardEncode CancelRequest where standardEncode (CancelRequest body boookingId) = standardEncode body
instance showCancelRequest :: Show CancelRequest where show = genericShow
instance decodeCancelRequest :: Decode CancelRequest where decode = defaultDecode
instance encodeCancelRequest  :: Encode CancelRequest where encode = defaultEncode   
-------------------------------------------------------------------------------RideBookingList API Types ------------------------------------------------------------

data RideBookingListReq = RideBookingListReq String String String

newtype RideBookingListRes = RideBookingListRes {
  list :: Array RideBookingRes
}

derive instance genericRideBookingListReq:: Generic RideBookingListReq _
instance standardRideBookingListReq :: StandardEncode RideBookingListReq where standardEncode (RideBookingListReq offset limit onlyActive) = standardEncode offset
instance showRideBookingListReq :: Show RideBookingListReq where show = genericShow
instance decodeRideBookingListReq :: Decode RideBookingListReq where decode = defaultDecode
instance encodeRideBookingListReq :: Encode RideBookingListReq where encode = defaultEncode  

derive instance genericRideBookingListRes:: Generic RideBookingListRes _
derive instance newtypeRideBookingListRes :: Newtype RideBookingListRes _
instance standardRideBookingListRes :: StandardEncode RideBookingListRes where standardEncode (RideBookingListRes body) = standardEncode body
instance showRideBookingListRes :: Show RideBookingListRes where show = genericShow
instance decodeRideBookingListRes :: Decode RideBookingListRes where decode = defaultDecode
instance encodeRideBookingListRes :: Encode RideBookingListRes where encode = defaultEncode  


instance makeRideBookingListReq :: RestEndpoint RideBookingListReq RideBookingListRes where
 makeRequest reqBody@(RideBookingListReq limit offset onlyActive ) headers = defaultMakeRequest GET (EP.rideBookingList limit offset onlyActive) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req




------------------------------------------------------------------------ CallDriver API TYPES -----------------------------------------------------------------------------------------
data CallDriverReq = CallDriverReq String

newtype CallDriverRes = CallDriverRes {
  callId :: String
}

instance makeCallDriverReq :: RestEndpoint CallDriverReq CallDriverRes where
  makeRequest reqBody@(CallDriverReq rideId) headers = defaultMakeRequest POST (EP.callCustomerToDriver rideId) headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericCallDriverReq :: Generic CallDriverReq _
instance standardEncodeCallDriverReq :: StandardEncode CallDriverReq where standardEncode (CallDriverReq body) = standardEncode body
instance showCallDriverReq :: Show CallDriverReq where show = genericShow
instance decodeCallDriverReq :: Decode CallDriverReq where decode = defaultDecode
instance encodeCallDriverReq  :: Encode CallDriverReq where encode = defaultEncode   

derive instance genericCallDriverRes :: Generic CallDriverRes _
derive instance newtypeCallDriverRes :: Newtype CallDriverRes _
instance standardEncodeCallDriverRes :: StandardEncode CallDriverRes where standardEncode (CallDriverRes body) = standardEncode body
instance showCallDriverRes :: Show CallDriverRes where show = genericShow
instance decodeCallDriverRes :: Decode CallDriverRes where decode = defaultDecode
instance encodeCallDriverRes  :: Encode CallDriverRes where encode = defaultEncode 


newtype FeedbackReq = FeedbackReq
  { rating :: Int
  , rideId :: String
  , feedbackDetails :: String
  }

newtype FeedbackRes = FeedbackRes
  {
    result :: String
  }

instance makeFeedBackReq :: RestEndpoint FeedbackReq FeedbackRes where
  makeRequest reqBody headers = defaultMakeRequest POST (EP.feedback "") headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericFeedbackReq :: Generic FeedbackReq _
instance standardEncodeFeedbackReq :: StandardEncode FeedbackReq where standardEncode (FeedbackReq body) = standardEncode body
instance showFeedbackReq :: Show FeedbackReq where show = genericShow
instance decodeFeedbackReq :: Decode FeedbackReq where decode = defaultDecode
instance encodeFeedbackReq  :: Encode FeedbackReq where encode = defaultEncode   

derive instance genericFeedbackRes :: Generic FeedbackRes _
derive instance newtypeFeedbackRes :: Newtype FeedbackRes _
instance standardEncodeFeedbackRes :: StandardEncode FeedbackRes where standardEncode (FeedbackRes body) = standardEncode body
instance showFeedbackRes :: Show FeedbackRes where show = genericShow
instance decodeFeedbackRes :: Decode FeedbackRes where decode = defaultDecode
instance encodeFeedbackRes  :: Encode FeedbackRes where encode = defaultEncode 


data GetProfileReq = GetProfileReq

newtype GetProfileRes = GetProfileRes 
  {
    middleName ::Maybe String
  , lastName :: Maybe String
  , maskedDeviceToken :: Maybe String
  , firstName :: Maybe String
  , id :: String
  , maskedMobileNumber :: Maybe String
  , maskedEmail :: Maybe String
  , hasTakenRide :: Boolean
  , referralCode :: Maybe String
  , language :: Maybe String
  }



newtype UpdateProfileReq = UpdateProfileReq 
  {
    middleName :: Maybe String
  , lastName :: Maybe String 
  , deviceToken :: Maybe String
  , firstName :: Maybe String
  , email :: Maybe String
  , referralCode :: Maybe String
  , language :: Maybe String
  }

newtype UpdateProfileRes = UpdateProfileRes
  {
    result :: String
  }

instance makeGetProfileReq :: RestEndpoint GetProfileReq GetProfileRes where
  makeRequest reqBody headers = defaultMakeRequest GET (EP.profile "") headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

instance makeUpdateProfileReq :: RestEndpoint UpdateProfileReq UpdateProfileRes where
  makeRequest reqBody headers = defaultMakeRequest POST (EP.profile "") headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericGetProfileRes :: Generic GetProfileRes _
derive instance newtypeGetProfileRes :: Newtype GetProfileRes _
instance standardEncodeGetProfileRes :: StandardEncode GetProfileRes where standardEncode (GetProfileRes body) = standardEncode body
instance showGetProfileRes :: Show GetProfileRes where show = genericShow
instance decodeGetProfileRes :: Decode GetProfileRes where decode = defaultDecode
instance encodeGetProfileRes  :: Encode GetProfileRes where encode = defaultEncode 

derive instance genericGetProfileReq :: Generic GetProfileReq _
instance standardEncodeGetProfileReq :: StandardEncode GetProfileReq where standardEncode (GetProfileReq) = standardEncode {}
instance showGetProfileReq :: Show GetProfileReq where show = genericShow
instance decodeGetProfileReq :: Decode GetProfileReq where decode = defaultDecode
instance encodeGetProfileReq  :: Encode GetProfileReq where encode = defaultEncode 

derive instance genericUpdateProfileReq :: Generic UpdateProfileReq _
derive instance newtypeUpdateProfileReq :: Newtype UpdateProfileReq _
instance standardEncodeUpdateProfileReq :: StandardEncode UpdateProfileReq where standardEncode (UpdateProfileReq body) = standardEncode body
instance showUpdateProfileReq :: Show UpdateProfileReq where show = genericShow
instance decodeUpdateProfileReq :: Decode UpdateProfileReq where decode = defaultDecode
instance encodeUpdateProfileReq  :: Encode UpdateProfileReq where encode = defaultEncode 

derive instance genericUpdateProfileRes :: Generic UpdateProfileRes _
derive instance newtypeUpdateProfileRes :: Newtype UpdateProfileRes _
instance standardEncodeUpdateProfileRes :: StandardEncode UpdateProfileRes where standardEncode (UpdateProfileRes body) = standardEncode body
instance showUpdateProfileRes :: Show UpdateProfileRes where show = genericShow
instance decodeUpdateProfileRes :: Decode UpdateProfileRes where decode = defaultDecode
instance encodeUpdateProfileRes  :: Encode UpdateProfileRes where encode = defaultEncode 

newtype GetRouteReq = GetRouteReq {
  waypoints :: Array LatLong
, mode :: Maybe String 
, calcPoints :: Boolean
}

newtype GetRouteResp = GetRouteResp (Array Route)
  
newtype Route = Route 
  {
    points :: Snapped
  , boundingBox :: Maybe (Array Number)
  , snappedWaypoints :: Array (Snapped)
  , duration :: Int
  , distance :: Int
  }

newtype BoundingLatLong = BoundingLatLong (Array Number)

newtype Snapped = Snapped (Array LatLong)

instance makeUpdateGetRouteReq :: RestEndpoint GetRouteReq GetRouteResp where
  makeRequest reqBody headers = defaultMakeRequest POST (EP.getRoute "") headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericGetRouteReq :: Generic GetRouteReq _
derive instance newtypeGetRouteReq :: Newtype GetRouteReq _
instance standardEncodeGetRouteReq :: StandardEncode GetRouteReq where standardEncode (GetRouteReq body) = standardEncode body
instance showGetRouteReq :: Show GetRouteReq where show = genericShow
instance decodeGetRouteReq :: Decode GetRouteReq where decode = defaultDecode
instance encodeGetRouteReq  :: Encode GetRouteReq where encode = defaultEncode 

derive instance genericRoute :: Generic Route _
derive instance newtypeRoute :: Newtype Route _
instance standardEncodeRoute :: StandardEncode Route where standardEncode (Route body) = standardEncode body
instance showRoute :: Show Route where show = genericShow
instance decodeRoute :: Decode Route where decode = defaultDecode
instance encodeRoute:: Encode Route where encode = defaultEncode

derive instance genericGetRouteResp :: Generic GetRouteResp _
derive instance newtypeGetRouteResp :: Newtype GetRouteResp _
instance standardEncodeGetRouteResp :: StandardEncode GetRouteResp where standardEncode (GetRouteResp body) = standardEncode body
instance showGetRouteResp :: Show GetRouteResp where show = genericShow
instance decodeGetRouteResp :: Decode GetRouteResp where decode = defaultDecode
instance encodeGetRouteResp  :: Encode GetRouteResp where encode = defaultEncode 

derive instance genericSnapped :: Generic Snapped _
derive instance newtypeSnapped :: Newtype Snapped _
instance standardEncodeSnapped :: StandardEncode Snapped where standardEncode (Snapped body) = standardEncode body
instance showSnapped :: Show Snapped where show = genericShow
instance decodeSnapped :: Decode Snapped where decode = defaultDecode
instance encodeSnapped  :: Encode Snapped where encode = defaultEncode 

derive instance genericBoundingLatLong :: Generic BoundingLatLong _
derive instance newtypeBoundingLatLong :: Newtype BoundingLatLong _
instance standardEncodeBoundingLatLong :: StandardEncode BoundingLatLong where standardEncode (BoundingLatLong body) = standardEncode body
instance showBoundingLatLong :: Show BoundingLatLong where show = genericShow
instance decodeBoundingLatLong :: Decode BoundingLatLong where decode = defaultDecode
instance encodeBoundingLatLong  :: Encode BoundingLatLong where encode = defaultEncode 

data GetDriverLocationReq = GetDriverLocationReq String

newtype GetDriverLocationResp = GetDriverLocationResp LatLong

instance makeGetDriverLocationReq :: RestEndpoint GetDriverLocationReq GetDriverLocationResp where
  makeRequest reqBody@(GetDriverLocationReq rideId) headers = defaultMakeRequest POST (EP.getCurrentLocation rideId) headers reqBody
  decodeResponse = decodeJSON
  encodeRequest req = standardEncode req

derive instance genericGetDriverLocationResp :: Generic GetDriverLocationResp _
derive instance newtypeGetDriverLocationResp :: Newtype GetDriverLocationResp _
instance standardEncodeGetDriverLocationResp :: StandardEncode GetDriverLocationResp where standardEncode (GetDriverLocationResp body) = standardEncode body
instance showGetDriverLocationResp :: Show GetDriverLocationResp where show = genericShow
instance decodeGetDriverLocationResp :: Decode GetDriverLocationResp where decode = defaultDecode
instance encodeGetDriverLocationResp  :: Encode GetDriverLocationResp where encode = defaultEncode 

derive instance genericGetDriverLocationReq :: Generic GetDriverLocationReq _
instance standardEncodeGetDriverLocationReq :: StandardEncode GetDriverLocationReq where standardEncode (GetDriverLocationReq rideId) = standardEncode rideId
instance showGetDriverLocationReq :: Show GetDriverLocationReq where show = genericShow
instance decodeGetDriverLocationReq :: Decode GetDriverLocationReq where decode = defaultDecode
instance encodeGetDriverLocationReq  :: Encode GetDriverLocationReq where encode = defaultEncode 

newtype SavedReqLocationAPIEntity = SavedReqLocationAPIEntity 
  { area :: Maybe String
  , state :: Maybe String
  , tag :: String 
  , country :: Maybe String
  , building :: Maybe String
  , door :: Maybe String
  , street :: Maybe String
  , lat :: Number 
  , city :: Maybe String 
  , areaCode :: Maybe String
  , lon :: Number
  , placeId :: Maybe String
  , ward :: Maybe String
}

data AddLocationResp = AddLocationResp

instance makeSavedReqLocationAPIEntity :: RestEndpoint SavedReqLocationAPIEntity AddLocationResp where
 makeRequest reqBody headers = defaultMakeRequest POST (EP.addLocation "") headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req
 
derive instance genericSavedReqLocationAPIEntity :: Generic SavedReqLocationAPIEntity _
derive instance newtypeSavedReqLocationAPIEntity :: Newtype SavedReqLocationAPIEntity _
instance standardEncodeSavedReqLocationAPIEntity :: StandardEncode SavedReqLocationAPIEntity where standardEncode (SavedReqLocationAPIEntity id) = standardEncode id
instance showSavedReqLocationAPIEntity:: Show SavedReqLocationAPIEntity where show = genericShow
instance decodeSavedReqLocationAPIEntity :: Decode SavedReqLocationAPIEntity where decode = defaultDecode
instance encodeSavedReqLocationAPIEntity :: Encode SavedReqLocationAPIEntity where encode = defaultEncode

derive instance genericAddLocationResp :: Generic AddLocationResp _
instance standardEncodeAddLocationResp :: StandardEncode AddLocationResp where standardEncode (AddLocationResp) = standardEncode {}
instance decodeAddLocationResp :: Decode AddLocationResp where decode = defaultDecode
instance encodeAddLocationResp :: Encode AddLocationResp where encode = defaultEncode

data SavedLocationReq = SavedLocationReq 

newtype SavedLocationsListRes = SavedLocationsListRes
  {
    list :: Array SavedReqLocationAPIEntity
  }

instance savedLocationReq :: RestEndpoint SavedLocationReq SavedLocationsListRes where
 makeRequest reqBody headers = defaultMakeRequest GET (EP.savedLocation "") headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericSavedLocationReq :: Generic SavedLocationReq _
instance standardEncodeSavedLocationReq :: StandardEncode SavedLocationReq where standardEncode (SavedLocationReq) = standardEncode {}
instance decodeSavedLocationReq :: Decode SavedLocationReq where decode = defaultDecode
instance encodeSavedLocationReq :: Encode SavedLocationReq where encode = defaultEncode

derive instance genericSavedLocationsListRes:: Generic SavedLocationsListRes _
derive instance newtypeSavedLocationsListRes :: Newtype SavedLocationsListRes _
instance standardEncodeSavedLocationsListRes :: StandardEncode SavedLocationsListRes where standardEncode (SavedLocationsListRes id) = standardEncode id
instance showSavedLocationsListRes:: Show SavedLocationsListRes where show = genericShow
instance decodeSavedLocationsListRes :: Decode SavedLocationsListRes where decode = defaultDecode
instance encodeSSavedLocationsListRes :: Encode SavedLocationsListRes where encode = defaultEncode

data DeleteSavedLocationReq = DeleteSavedLocationReq String 

data DeleteSavedLocationRes = DeleteSavedLocationRes 

instance deleteSavedLocationReq :: RestEndpoint DeleteSavedLocationReq DeleteSavedLocationRes where
 makeRequest reqBody@(DeleteSavedLocationReq tag) headers = defaultMakeRequest DELETE (EP.deleteLocation tag) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req


derive instance genericDeleteSavedLocationReq :: Generic DeleteSavedLocationReq _
instance standardEncodeDeleteSavedLocationReq :: StandardEncode DeleteSavedLocationReq where standardEncode (DeleteSavedLocationReq tag) = standardEncode tag
instance decodeDeleteSavedLocationReq :: Decode DeleteSavedLocationReq where decode = defaultDecode
instance encodeDeleteSavedLocationReq :: Encode DeleteSavedLocationReq where encode = defaultEncode

derive instance genericDeleteSavedLocationRes :: Generic DeleteSavedLocationRes _
instance standardEncodeDeleteSavedLocationRes :: StandardEncode DeleteSavedLocationRes where standardEncode (DeleteSavedLocationRes) = standardEncode {}
instance decodeDeleteSavedLocationRes :: Decode DeleteSavedLocationRes where decode = defaultDecode
instance encodeDeleteSavedLocationRes :: Encode DeleteSavedLocationRes where encode = defaultEncode


newtype SendIssueReq = SendIssueReq
  {
    contactEmail :: Maybe String
  , rideBookingId :: Maybe String 
  , issue :: Issue 
  }

newtype Issue = Issue 
  {
    reason :: String 
  , description :: String
  }

newtype SendIssueRes = SendIssueRes {
    result :: String
  }

instance makeSendIssueReq :: RestEndpoint SendIssueReq SendIssueRes where
    makeRequest reqBody headers = defaultMakeRequest POST (EP.sendIssue "") headers reqBody
    decodeResponse = decodeJSON
    encodeRequest req = defaultEncode req

derive instance genericSendIssueReq :: Generic SendIssueReq _
derive instance newtypeSendIssueReq :: Newtype SendIssueReq _
instance standardEncodeSendIssueReq :: StandardEncode SendIssueReq where standardEncode (SendIssueReq req) = standardEncode req
instance showSendIssueReq :: Show SendIssueReq where show = genericShow
instance decodeSendIssueReq :: Decode SendIssueReq where decode = defaultDecode
instance encodeSendIssueReq :: Encode SendIssueReq where encode = defaultEncode

derive instance genericIssue :: Generic Issue _
derive instance newtypeIssue:: Newtype Issue _
instance standardEncodeIssue :: StandardEncode Issue where standardEncode (Issue req) = standardEncode req
instance showIssue :: Show Issue where show = genericShow
instance decodeIssue :: Decode Issue where decode = defaultDecode
instance encodeIssue :: Encode Issue where encode = defaultEncode

derive instance genericSendIssueRes :: Generic SendIssueRes _
derive instance newtypeSendIssueRes :: Newtype SendIssueRes _
instance standardEncodeSendIssueRes :: StandardEncode SendIssueRes where standardEncode (SendIssueRes res) = standardEncode res
instance showSendIssueRes :: Show SendIssueRes where show = genericShow
instance decodeSendIssueRes :: Decode SendIssueRes where decode = defaultDecode
instance encodeSendIssueRes :: Encode SendIssueRes where encode = defaultEncode

newtype ServiceabilityReq = ServiceabilityReq 
  { location  :: LatLong
  }

newtype ServiceabilityRes = ServiceabilityRes 
  { serviceable :: Boolean
  }

instance makeOriginServiceabilityReq :: RestEndpoint ServiceabilityReq ServiceabilityRes where
    makeRequest reqBody headers = defaultMakeRequest POST (EP.serviceabilityOrigin "") headers reqBody
    decodeResponse = decodeJSON
    encodeRequest req = defaultEncode req

derive instance genericServiceabilityReq :: Generic ServiceabilityReq _
derive instance newtypeServiceabilityReq:: Newtype ServiceabilityReq _
instance standardEncodeServiceabilityReq :: StandardEncode ServiceabilityReq where standardEncode (ServiceabilityReq req) = standardEncode req
instance showServiceabilityReq :: Show ServiceabilityReq where show = genericShow
instance decodeServiceabilityReq :: Decode ServiceabilityReq where decode = defaultDecode
instance encodeServiceabilityReq :: Encode ServiceabilityReq where encode = defaultEncode

derive instance genericServiceabilityRes :: Generic ServiceabilityRes _
derive instance newtypeServiceabilityRes:: Newtype ServiceabilityRes _
instance standardEncodeServiceabilityRes :: StandardEncode ServiceabilityRes where standardEncode (ServiceabilityRes req) = standardEncode req
instance showServiceabilityRes :: Show ServiceabilityRes where show = genericShow
instance decodeServiceabilityRes :: Decode ServiceabilityRes where decode = defaultDecode
instance encodeServiceabilityRes :: Encode ServiceabilityRes where encode = defaultEncode

----------------------------------------------------------------------- flowStatus api -------------------------------------------------------------------

data FlowStatusReq = FlowStatusReq

newtype FlowStatusRes = FlowStatusRes
  { currentStatus :: FlowStatus 
  , oldStatus :: Maybe FlowStatus
  }

newtype FlowStatus = FlowStatus 
  { status :: String 
  , requestId :: Maybe String 
  , validTill :: Maybe String 
  , estimateId :: Maybe String 
  , bookingId :: Maybe String
  , rideId :: Maybe String 
  }

instance makeFlowStatusReq :: RestEndpoint FlowStatusReq FlowStatusRes where
    makeRequest reqBody headers = defaultMakeRequest GET (EP.flowStatus "") headers reqBody
    decodeResponse = decodeJSON
    encodeRequest req = defaultEncode req

derive instance genericFlowStatusReq :: Generic FlowStatusReq _
instance standardEncodeFlowStatusReq :: StandardEncode FlowStatusReq where standardEncode (FlowStatusReq) = standardEncode {}
instance decodeFlowStatusReq :: Decode FlowStatusReq where decode = defaultDecode
instance encodeFlowStatusReq :: Encode FlowStatusReq where encode = defaultEncode

derive instance genericFlowStatusRes :: Generic FlowStatusRes _
derive instance newtypeFlowStatusRes:: Newtype FlowStatusRes _
instance standardEncodeFlowStatusRes :: StandardEncode FlowStatusRes where standardEncode (FlowStatusRes req) = standardEncode req
instance showFlowStatusRes :: Show FlowStatusRes where show = genericShow
instance decodeFlowStatusRes :: Decode FlowStatusRes where decode = defaultDecode
instance encodeFlowStatusRes :: Encode FlowStatusRes where encode = defaultEncode

derive instance genericFlowStatus :: Generic FlowStatus _
derive instance newtypeFlowStatus:: Newtype FlowStatus _
instance standardEncodeFlowStatus :: StandardEncode FlowStatus where standardEncode (FlowStatus req) = standardEncode req
instance showFlowStatus :: Show FlowStatus where show = genericShow
instance decodeFlowStatus :: Decode FlowStatus where decode = defaultDecode
instance encodeFlowStatus :: Encode FlowStatus where encode = defaultEncode

----------------------------------------------------------------------- notifyFlowEvent api -------------------------------------------------------------------

newtype NotifyFlowEventReq = NotifyFlowEventReq
  { event :: String }

newtype NotifyFlowEventRes = NotifyFlowEventRes
  { result :: String }

instance makeNotifyFlowEventReq :: RestEndpoint NotifyFlowEventReq NotifyFlowEventRes where
 makeRequest reqBody headers = defaultMakeRequest POST (EP.notifyFlowEvent "") headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericNotifyFlowEventReq :: Generic NotifyFlowEventReq _
derive instance newtypeNotifyFlowEventReq :: Newtype NotifyFlowEventReq _
instance standardEncodeNotifyFlowEventReq :: StandardEncode NotifyFlowEventReq where standardEncode (NotifyFlowEventReq req) = standardEncode req
instance showNotifyFlowEventReq :: Show NotifyFlowEventReq where show = genericShow
instance decodeNotifyFlowEventReq :: Decode NotifyFlowEventReq where decode = defaultDecode
instance encodeNotifyFlowEventReq :: Encode NotifyFlowEventReq where encode = defaultEncode

derive instance genericNotifyFlowEventRes :: Generic NotifyFlowEventRes _
derive instance newtypeNotifyFlowEventRes :: Newtype NotifyFlowEventRes _
instance standardEncodeNotifyFlowEventRes :: StandardEncode NotifyFlowEventRes where standardEncode (NotifyFlowEventRes res) = standardEncode res
instance showNotifyFlowEventRes :: Show NotifyFlowEventRes where show = genericShow
instance decodeNotifyFlowEventRes :: Decode NotifyFlowEventRes where decode = defaultDecode
instance encodeNotifyFlowEventRes :: Encode NotifyFlowEventRes where encode = defaultEncode

----------------------------------------------------------------------- cancelEstimate api -------------------------------------------------------------------

data CancelEstimateReq = CancelEstimateReq String

newtype CancelEstimateRes = CancelEstimateRes
  {
    result :: String 
  }

instance makeCancelEstimateReq :: RestEndpoint CancelEstimateReq CancelEstimateRes where
 makeRequest reqBody@(CancelEstimateReq estimateId) headers = defaultMakeRequest POST (EP.cancelEstimate estimateId) headers reqBody
 decodeResponse = decodeJSON
 encodeRequest req = standardEncode req

derive instance genericCancelEstimateRes :: Generic CancelEstimateRes _
derive instance newtypeCancelEstimateRes :: Newtype CancelEstimateRes _
instance standardEncodeCancelEstimateRes :: StandardEncode CancelEstimateRes where standardEncode (CancelEstimateRes body) = standardEncode body
instance showCancelEstimateRes :: Show CancelEstimateRes where show = genericShow
instance decodeCancelEstimateRes :: Decode CancelEstimateRes where decode = defaultDecode
instance encodeCancelEstimateRes  :: Encode CancelEstimateRes where encode = defaultEncode   

derive instance genericCancelEstimateReq :: Generic CancelEstimateReq _
instance standardEncodeCancelEstimateReq :: StandardEncode CancelEstimateReq where standardEncode (CancelEstimateReq body) = standardEncode body
instance showCancelEstimateReq :: Show CancelEstimateReq where show = genericShow
instance decodeCancelEstimateReq :: Decode CancelEstimateReq where decode = defaultDecode
instance encodeCancelEstimateReq  :: Encode CancelEstimateReq where encode = defaultEncode