module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, input, h2, textarea)
import Html.Attributes exposing (type_, classList)
import Html.Events exposing (onClick)
import Http
import Types exposing (..)
import Utility exposing (httpErrorDecode)


endpoint = "http://192.168.0.194:8080"

type Model 
  = ListMode Daily
  | DetailMode Exercise 
  | Loading
  | Failure String

type Msg
  = ViewList
  | ViewDetail Exercise
  | GotExercise (Result Http.Error Daily)
  | CreateExecution Exercise
  | InsertExecutionStatus (Result Http.Error ())


getExerciseList : Cmd Msg
getExerciseList =
  Http.riskyRequest
    { url = endpoint ++ "/get_daily"
    , method = "get"
    , headers = []
    , body = Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectJson GotExercise dailyDecoder
    }

createExecution : Cmd Msg
createExecution =
  Http.riskyRequest
    { url = endpoint ++ "/insert_execution"
    , method = "post"
    , headers = []
    , body = Http.emptyBody
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectWhatever InsertExecutionStatus
    }

exerciseElement : Exercise -> Html Msg
exerciseElement exercise = 
    div [ onClick (ViewDetail exercise) 
        , classList 
            [ ("is_done", exercise.is_done)
            , ("exerciseElement", True) 
            ]
        ] 
        [ div [ ] [ text exercise.name ]
        , div [ ] [ text exercise.description ]
        ]

init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getExerciseList)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    ViewList ->
        (model, getExerciseList)
    ViewDetail exercise ->
        (DetailMode exercise, Cmd.none)
    CreateExecution exercise -> 
        (model, createExecution)
    GotExercise result -> 
      case result of
        Ok daily ->
          (ListMode daily, Cmd.none)
        Err err ->
          (Failure (httpErrorDecode err), Cmd.none)
    InsertExecutionStatus result -> 
      case result of
        Ok _ ->
          (update ViewList model)
        Err _ ->
          (model, Cmd.none)
      

-- VIEW
view : Model -> Html Msg
view model =
  case model of 
    Loading -> 
      div [ classList [ ("loading", True) ] ] [ text "Loading..." ]
    Failure err -> 
      div [ classList [ ("error", True) ] ] [ text "Error!" ]
    ListMode daily ->
      div [ classList [ ("dailyContainer", True ) ] ] 
          [ h2 [ classList [ ("title", True ) ] ] [ text daily.weekday ]
          , div [ classList [ ("dailyContainer", True ) ] ] 
            (List.map exerciseElement daily.exercises) 
          ]
    DetailMode detail -> 
      div [ classList [ ("detailContainer", True) ] ]
          [ div [] [ text detail.name ]
          , div [] [ text detail.description ]
          , div [] [ text <| (String.fromInt detail.weight) ++ " kg" ]
          , div [ classList [ ("setContainer", True ) ] ] 
                <| List.repeat detail.sets 
                <| div [ classList [ ("repContainer", True)] ]
                    [ input [ type_ "number"] [] 
                    , div [] [ text "/" ]
                    , div [] [ text <| String.fromInt detail.reps ]
                    ]
          , textarea [] []
          , button [ onClick ViewList ] [ text "Go Back" ]
          , button [ onClick (CreateExecution detail) ] [ text "Complete" ]
          ]

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

