module Pages.PlanList exposing (..)

import Browser
import Html exposing (Html, button, div, text, input, h2, textarea, a)
import Html.Attributes exposing (type_, classList, placeholder, value, href)
import Html.Events exposing (onClick, onInput)
import Http
import Types exposing (..)
import Utility exposing (httpErrorDecode)
import Array
import Browser.Navigation as Nav

import Browser
import Html exposing (Html, button, div, text, input, a, textarea, label, br, option, select, h2, label)
import Html.Attributes exposing (type_, classList, placeholder, value, href, name, for, disabled)
import Html.Events exposing (onClick, onInput)
import Http
import Types exposing (..)
import Utility exposing (httpErrorDecode)
import Array




endpoint : String
endpoint = "http://192.168.0.194:8080"

type Model
  --General status
  = Loading
  | Failure String
  --Pages
  | PlanList (List ExercisePlan)
  | PlanDetail ExercisePlan



type Msg
  --Render pages
  = ViewList
  | ViewDetail ExercisePlan
  --Http Results
  | GotPlanList (Result Http.Error (List ExercisePlan))
  --Input
  | InputName String
  | InputDescription String
  | InputMinRep String
  | InputMaxRep String
  | InputMinSet String
  | InputMaxSet String
  | InputWeight String
  | InputWeightStep String
  -- Insert
  | InsertPlan
  | UpdatePlan 
  | InsertPlanStatus (Result Http.Error ())
  -- Weekday
  | AddWeekday String
  | RemoveWeekday String



getPlanList : Cmd Msg
getPlanList =
  Http.riskyRequest
    { url = endpoint ++ "/get_plan_list"
    , method = "get"
    , headers = []
    , body = Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectJson GotPlanList planListDecoder 
    }

insertPlan : ExercisePlan -> Cmd Msg
insertPlan plan =
  Http.riskyRequest
    { url = endpoint ++ "/insert_plan"
    , method = "post"
    , headers = []
    , body = Http.jsonBody (encodePlan plan)
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectWhatever InsertPlanStatus
    }

updatePlan : ExercisePlan -> Cmd Msg
updatePlan plan =
  Http.riskyRequest
    { url = endpoint ++ "/update_plan"
    , method = "post"
    , headers = []
    , body = Http.jsonBody (encodePlan plan)
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectWhatever InsertPlanStatus
    }


init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getPlanList)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case model of 
        Loading -> 
            case msg of 
                GotPlanList result ->
                    case result of 
                        Ok list ->
                            (PlanList list, Cmd.none)
                        Err err -> 
                            (Failure (httpErrorDecode err), Cmd.none)
                _ -> 
                    (model, Cmd.none)
        PlanList list -> 
            case msg of 
                ViewDetail plan ->
                    (PlanDetail plan, Cmd.none)
                InsertPlanStatus result ->
                    case result of
                        Ok _ ->
                            (model, Cmd.none)
                        Err _ ->
                            (model, Cmd.none)
                _ ->
                    (model, Cmd.none)
        PlanDetail plan ->
            case msg of 
                ViewList ->
                    (model, getPlanList)
                InsertPlanStatus result ->
                    case result of
                        Ok _ ->
                            (update ViewList model)
                        Err _ ->
                            (model, Cmd.none)
                InsertPlan ->
                    (model, insertPlan plan)
                InputName value ->
                      ( PlanDetail { plan | name = value}, Cmd.none)
                InputDescription value ->
                      ( PlanDetail { plan | description = value}, Cmd.none)
                InputMinRep value ->
                      ( PlanDetail { plan | min_reps = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                InputMaxRep value ->
                      ( PlanDetail { plan | max_reps = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                InputMinSet value ->
                      ( PlanDetail { plan | min_sets = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                InputMaxSet value ->
                      ( PlanDetail { plan | max_sets = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                InputWeight value ->
                      ( PlanDetail { plan | min_weight = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                InputWeightStep value ->
                      ( PlanDetail { plan | weight_step = Maybe.withDefault 1 <| String.toInt value}, Cmd.none)
                AddWeekday item ->
                      if (String.length item) > 0 then
                          (PlanDetail { plan | weekday = plan.weekday ++ [item] }, Cmd.none)
                      else 
                          (model, Cmd.none)
                RemoveWeekday item ->
                      let 
                          (_, newSelected) = List.partition (\x -> x == item) plan.weekday
                      in
                      (PlanDetail { plan |  weekday = newSelected }, Cmd.none)

                _ -> 
                    (model, Cmd.none)
        _ -> 
            (model, Cmd.none)

weekdayOption :  ExercisePlan -> String -> Html Msg
weekdayOption plan value  =
  option [ disabled <| List.member value plan.weekday ] [ text value ]
  

removeWeekday : String -> Html Msg
removeWeekday value =
    div [ classList [ ("weekdays", True) ] ] 
    [ div [] [ text value ]
    , button [ onClick (RemoveWeekday value)] [ text "x" ]
    ]

planElement : ExercisePlan -> Html Msg
planElement plan =
    div [ onClick (ViewDetail plan)
        , classList
            [ ("exerciseElement", True)
            ]
        ]
        [ div [ ] [ text plan.name ]
        , div [ ] [ text plan.description ]
        ]

planDefault : ExercisePlan 
planDefault = 
    { id_plan = Nothing
    , name = ""
    , description = ""
    , weekday = []
    , min_reps = 0
    , max_reps = 0
    , min_sets = 0
    , max_sets = 0
    , min_weight = 0
    , weight_step = 0
    , active = True
    }

-- VIEW
view : Model -> Html Msg
view model =
  case model of
    Loading ->
      div [ classList [ ("loading", True) ] ] [ text "Loading..." ]
    Failure err ->
      div [] 
        [ div [ classList [ ("error", True) ] ] [ text <| "Error!" ++ err ]
        , a [ href "/login"] [ text "Return to login page" ]
        ]
    PlanList list ->
        div [ classList [ ("dailyContainer", True ) ] ]
            [ h2 [ classList [ ("title", True ) ] ] [ text "Plan List" ]
            , div [ classList [ ("dailyContainer", True ) ] ]
            (List.map planElement list)
            , button 
                [ classList [ ("fabs", True) ]
                , onClick (ViewDetail planDefault)
                ] [ text "+" ]
            ]
    PlanDetail detail ->
        let 
            content = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
        in
        div [ classList [ ("planContainer", True) ] ] 
        [ h2 [] [ text "New Plan" ]
        , input [ placeholder "Name", onInput InputName, value detail.name ] []
        , input [ placeholder "Description", onInput InputDescription, value detail.description] []
        , div [ ]
            [ select [ onInput AddWeekday ] 
                <| List.append 
                    [option [ value "" ] [ text "Select one..."] ]
                    (List.map (weekdayOption detail) content )
            , div [] (List.map removeWeekday detail.weekday ) 
            ]
        , label [ for "min_rep" ] [ text "Min. reps" ]
        , input [ name "min_rep", placeholder "Min rep", onInput InputMinRep, type_ "number", value (String.fromInt detail.min_reps)] []

        , label [ for "max_rep" ] [ text "Max. reps" ]
        , input [ name "max_rep", placeholder "Max rep", onInput InputMaxRep, type_ "number", value (String.fromInt detail.max_reps) ] []

        , label [ for "min_set" ] [ text "Min. sets" ]
        , input [ name "min_set", placeholder "Min set", onInput InputMinSet, type_ "number", value (String.fromInt detail.min_sets)] []

        , label [ for "max_set" ] [ text "Max. sets" ]
        , input [ name "max_set", placeholder "Max set", onInput InputMaxSet, type_ "number", value (String.fromInt detail.max_sets)] []

        , label [ for "weight" ] [ text "Weight" ]
        , input [ name "weight", placeholder "Weight", onInput InputWeight, type_ "number", value (String.fromInt detail.min_weight)] []

        , label [ for "weight_step" ] [ text "Weight Increment" ]
        , input [ name "weight_step", placeholder "Weight step", onInput InputWeightStep, type_ "number", value (String.fromInt detail.weight_step)] []
        , a [ href "/", classList [ ("btnReturn", True)]  ] [ text "Go Back" ]
        , case detail.id_plan of
            Just id ->
                button [ onClick UpdatePlan ] [ text "Save" ]
            Nothing -> 
                button [ onClick InsertPlan ] [ text "Save" ]
        ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

