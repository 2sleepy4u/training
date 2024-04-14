module Types exposing (..)
import Json.Decode as JD exposing (field, Decoder, int, string, list, bool, succeed)
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
  , min_reps: Int
  , max_reps: Int
  , min_sets: Int
  , max_sets: Int
  , weight: Int
  , weight_step: Int
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


