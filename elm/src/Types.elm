module Types exposing (..)
import Json.Decode as JD exposing (field, Decoder, int, string, list, bool, succeed, null)
import Json.Decode.Pipeline exposing (required, optional)
import Json.Encode as JE 

type alias Daily =
    { weekday: String
    , exercises: List Exercise
    }

type alias ExercisePlan = 
  { id_plan: Maybe Int
  , name: String
  , description: String
  , weekday: List String
  , min_reps: Int
  , max_reps: Int
  , min_sets: Int
  , max_sets: Int
  , min_weight: Int
  , weight_step: Int
  , active: Bool
  }

type alias Exercise = 
  { id_plan: Int
  , name: String
  , description: String
  , reps: Int
  , sets: Int
  , weight: Int
  , is_done: Bool
  , note: String 
  , done_reps: List Int
  }

encodePlan : ExercisePlan -> JE.Value
encodePlan plan =
    JE.object
        [ ( "id_plan", JE.int <| Maybe.withDefault -1 plan.id_plan )
        , ( "name", JE.string plan.name)
        , ( "description", JE.string plan.description)
        , ( "weekday", JE.list JE.string plan.weekday )
        , ( "min_reps", JE.int plan.min_reps )
        , ( "max_reps", JE.int plan.max_reps )
        , ( "min_sets", JE.int plan.min_sets )
        , ( "max_sets", JE.int plan.max_sets )
        , ( "min_weight", JE.int plan.min_weight )
        , ( "weight_step", JE.int plan.weight_step )
        , ( "active", JE.bool plan.active )
        ]

planListDecoder : Decoder (List ExercisePlan) 
planListDecoder =
  JD.list planDecoder

planDecoder : Decoder ExercisePlan 
planDecoder =
    JD.succeed ExercisePlan
        |> required "id_plan" (JD.maybe int)
        |> required "name" string
        |> required "description" string
        |> required "weekday" (list string)
        |> required "min_reps" int
        |> required "max_reps" int
        |> required "min_sets" int
        |> required "max_sets" int
        |> required "min_weight" int
        |> required "weight_step" int
        |> required "active" bool




exerciseDecoder : Decoder Exercise
exerciseDecoder =
    JD.succeed Exercise
        |> required "id_plan" int
        |> required "name" string
        |> required "description" string
        |> required "reps" int
        |> required "sets" int
        |> required "weight" int
        |> required "is_done" bool
        |> optional "note" string ""
        |> optional "done_reps" (list int) []


dailyDecoder : Decoder Daily
dailyDecoder =
    JD.map2 Daily
        (field "weekday" string)
        (field "exercises" (list exerciseDecoder))

exerciseListDecoder : Decoder (List Exercise) 
exerciseListDecoder =
  JD.list exerciseDecoder

encodeExecution : Exercise -> JE.Value
encodeExecution exercise =
    JE.object
        [ ( "id_plan", JE.int exercise.id_plan )
        , ( "weight", JE.int exercise.weight)
        , ( "note", JE.string exercise.note )
        , ( "reps", JE.list JE.int exercise.done_reps )
        ]


