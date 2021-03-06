{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

module Quickstrom.Gen where

import qualified Data.List.NonEmpty as NonEmpty
import Data.Maybe (fromMaybe)
import Data.Text (Text)
import qualified Data.Text as Text
import Quickstrom.Action
import Quickstrom.Element
import Quickstrom.Trace hiding (observedStates)
import Test.QuickCheck hiding ((===), (==>))
import Prelude hiding (Bool (..))

selector :: Gen Selector
selector = elements (map (Selector . Text.singleton) ['a' .. 'c'])

selected :: Gen Selected
selected = Selected <$> selector <*> choose (0, 3)

stringValues :: Gen Text
stringValues = elements ["s1", "s2", "s3"]

observedState :: Gen ObservedState
observedState = pure mempty

selectedAction :: Gen (Action Selected)
selectedAction =
  oneof
    [ Focus <$> selected,
      KeyPress <$> elements ['A' .. 'C'],
      Click <$> selected
    ]

selectedActionSequence :: Gen (ActionSequence Selected)
selectedActionSequence = Single <$> selectedAction

actionResult :: Gen ActionResult
actionResult = oneof [pure ActionSuccess, pure (ActionFailed "failed"), pure ActionImpossible]

traceElement :: Gen (TraceElement ())
traceElement =
  oneof
    [ TraceAction () <$> selectedActionSequence <*> actionResult,
      TraceState () <$> observedState
    ]

trace :: Gen (Trace ())
trace = Trace <$> listOf traceElement

nonEmpty :: Gen [a] -> Gen (NonEmpty.NonEmpty a)
nonEmpty g = fromMaybe discard . NonEmpty.nonEmpty <$> g
