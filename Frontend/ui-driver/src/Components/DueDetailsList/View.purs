{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Components.DueDetailsList.View where

import Common.Types.App
import Components.DueDetailsList.Controller

import Data.Array (mapWithIndex)
import Effect (Effect)
import Font.Size as FontSize
import Font.Style as FontStyle
import Language.Types (STR(..))
import Prelude (Unit, (==), const, (<>), (&&), bind, ($), pure, unit, (/=), void)
import PrestoDOM (Gravity(..), Gradient(..), Length(..), Margin(..), Orientation(..), Visibility(..), PrestoDOM, Padding(..), alignParentBottom, padding, background, color, cornerRadius, fontStyle, gradient, gravity, height, imageUrl, imageView, linearLayout, margin, onClick, orientation, stroke, text, textSize, textView, weight, width, imageWithFallback, lottieAnimationView, id, afterRender, visibility)
import Styles.Colors as Color
import Screens.Types (PromoConfig)
import Debug (spy)
import Language.Strings (getString)
import Data.Maybe as Mb


view :: forall w . (Action -> Effect Unit) -> DueDetailsListState -> PrestoDOM (Effect Unit) w
view push state =
    linearLayout
    [ width MATCH_PARENT
    , height MATCH_PARENT
    ][ linearLayout
       [ width MATCH_PARENT
       , height MATCH_PARENT
       , orientation VERTICAL
       , margin (Margin 16 10 16 10)
       ](mapWithIndex
         (\index item ->
          linearLayout
          [ width MATCH_PARENT
          , height WRAP_CONTENT
          , weight 1.0
          , orientation VERTICAL
          , padding $ Padding 16 20 16 8
          , gravity CENTER
          , stroke if item.expanded == true then ("1,"<>Color.blue800) else ("1,"<>Color.grey900)
          , onClick push (const (SelectDue index))
          , margin $ MarginBottom 16
          , cornerRadius 10.0
          , background if item.expanded == true then Color.blue600 else Color.white900
          ][ 
            linearLayout[
              width MATCH_PARENT
              , height WRAP_CONTENT
              , margin $ MarginBottom 16
            ]
            [
              linearLayout[
                orientation VERTICAL
                , weight 1.0
              ][
                linearLayout[][
                  textView [
                    text (getString TRIP_DATE)
                    , textSize FontSize.a_12
                    , fontStyle $ FontStyle.medium LanguageStyle
                    , color Color.black700
                  ]
                  ,textView [
                    text item.date     
                    , textSize FontSize.a_14
                    , fontStyle $ FontStyle.bold LanguageStyle
                    , color Color.black800              
                  ]
                ]
                , textView [
                    text item.planType
                    , textSize FontSize.a_14
                    , fontStyle $ FontStyle.bold LanguageStyle
                    , color Color.black700
                  ]
              ]
              , linearLayout[
                height MATCH_PARENT
                , gravity CENTER
              ][
                textView [
                  text $ "₹" <> item.dueAmount
                  , textSize FontSize.a_18
                  , fontStyle $ FontStyle.bold LanguageStyle
                  , color Color.black800
                ]
                , imageView
                  [ imageWithFallback if item.expanded == true then "ny_ic_chevron_up,https://assets.juspay.in/nammayatri/images/common/ny_ic_chevron_up.png" else "ny_ic_chevron_down,https://assets.juspay.in/nammayatri/images/common/ny_ic_chevron_down.png"
                  , height (V 11)
                  , margin (Margin 5 3 0 0)
                  , width (V 11)
                  ]
              ]
            ]
            , linearLayout [
              orientation VERTICAL
              , width MATCH_PARENT
              , height WRAP_CONTENT
              , visibility if item.expanded == true then VISIBLE else GONE
            ][
                linearLayout [
                  height $ V 1
                  , width MATCH_PARENT
                  , background Color.grey900
                  , margin $ MarginBottom 16
                ][]
                , 
                linearLayout [
                  height WRAP_CONTENT
                  , width MATCH_PARENT
                  , margin $ MarginBottom 16
                  , gravity CENTER_VERTICAL
                ][ 
                  textView [
                    text $ getString OFFER_APPLIED
                    , textSize FontSize.a_12
                    , fontStyle $ FontStyle.medium LanguageStyle
                    , margin $ MarginRight 8
                    , color Color.black700
                  ]
                  , promoCodeView push item.offerApplied
                ]
                , keyValueView (getString NUMBER_OF_RIDES) item.noOfRides
                , keyValueView (getString YOUR_EARNINGS) ("₹" <> item.totalEarningsOfDay)
                , keyValueView (getString FARE_BREAKUP) item.fareBreakup
            ]
           ]
         ) state.dues
         )
    ]

keyValueView :: String -> String ->  forall w . PrestoDOM (Effect Unit) w
keyValueView key value = 
  linearLayout [
                  height WRAP_CONTENT
                  , width MATCH_PARENT
                  , margin $ MarginBottom 16
              ][ 
                textView [
                  text key
                  , textSize FontSize.a_12
                  , fontStyle $ FontStyle.medium LanguageStyle
                  , margin $ MarginRight 8
                  , color Color.black700
                ]
                , textView [
                  text value
                  , textSize FontSize.a_14
                  , fontStyle $ FontStyle.bold LanguageStyle
                  , color Color.black800
                ]
              ]

promoCodeView :: forall w. (Action -> Effect Unit) -> PromoConfig -> PrestoDOM (Effect Unit) w 
promoCodeView push state =
  linearLayout
  ([ height WRAP_CONTENT
  , width WRAP_CONTENT
  , cornerRadius 100.0
  , padding $ Padding 10 4 10 4
  , stroke $ "1," <> Color.grey900
  , background Color.white900
  , margin $ MarginRight 4
  , gravity CENTER_VERTICAL
  ]<> if state.isGradient then [gradient (Linear 90.0 state.gradient)] else [])
   [ imageView
     [ width $ V 12
     , height $ V 12
     , margin (MarginRight 4)
     , visibility if state.hasImage then VISIBLE else GONE
     , imageWithFallback state.imageURL
     ] 
   , textView $
     [ textSize FontSize.a_10
     , fontStyle $ FontStyle.medium LanguageStyle
     , color Color.blue900
     , padding $ PaddingBottom 3
     ] <> case state.title of
          Mb.Nothing -> [visibility GONE]
          Mb.Just txt -> [text txt]
  ]