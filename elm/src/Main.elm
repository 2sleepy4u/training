module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, input, h2, textarea)
import Html.Attributes exposing (type_, classList, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Types exposing (..)
import Utility exposing (httpErrorDecode)
import Array


endpoint : String
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
  | RepInput Int String


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

createExecution : Exercise -> Cmd Msg
createExecution exercise =
  Http.riskyRequest
    { url = endpoint ++ "/insert_execution"
    , method = "post"
    , headers = []
    , body = Http.jsonBody (encodeExecution exercise)
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
    RepInput set value -> 
        case model of 
            DetailMode detail -> 
                (DetailMode {detail | done_reps = Array.toList 
                    <| Array.set set (String.toInt value |> Maybe.withDefault 0) (Array.fromList (detail.done_reps)) 
                }, Cmd.none)
            _ ->
                (model, Cmd.none)
    ViewList ->
        (model, getExerciseList)
    ViewDetail exercise ->
        (DetailMode exercise, Cmd.none)
    CreateExecution exercise -> 
        (model, createExecution exercise)
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

createRepContainer :  Int -> Exercise -> Html Msg
createRepContainer index detail = 
    div [ classList [ ("repContainer", True)] ]
    [ input 
        [ type_ "number"
        , Html.Attributes.disabled detail.is_done
        , onInput  (RepInput index)
        , value <| String.fromInt <| (Array.get index (Array.fromList detail.done_reps) |> Maybe.withDefault 0 )
        ] [] 
    , div [] [ text "/" ]
    , div [] [ text <| String.fromInt detail.reps ]
    ]

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
                    <| List.indexedMap createRepContainer (List.repeat detail.sets detail)
              , textarea [ placeholder "Note", Html.Attributes.disabled detail.is_done ] []
              , button [ onClick ViewList ] [ text "Go Back" ]
              , if detail.is_done then 
                  div [] []
                else
                    button [ onClick (CreateExecution detail) ] [ text "Complete" ]
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

