{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.InvoiceScreen.ScreenData where

import Screens.Types (InvoiceScreenState)
import Screens.MyRidesScreen.ScreenData (dummyIndividualCard)
import MerchantConfig.DefaultConfig as DC
import Foreign.Object (empty)

initData :: InvoiceScreenState
initData = {
  data: {
    tripCharges : "",
    promotion : 0.0,
    gst : 0.0,
    totalAmount : "",
    date : "wed,10,45",
    selectedItem : dummyIndividualCard,
    config : DC.config,
    logField : empty
  },
  props: {
    paymentMode : "Cash"
  , fromHomeScreen : false
  }
}