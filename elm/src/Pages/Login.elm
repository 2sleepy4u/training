module Pages.Login exposing (..)
import Utility exposing (..)
import Html.Attributes exposing (type_, classList, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Html exposing (Html, div, button, input, text, form, h2)
import Browser
import Browser.Navigation as Nav
import Http
import Json.Encode as JE

endpoint : String
endpoint = "http://192.168.0.194:8080"

type alias Model =
    { email: String
    , password: String
    , error: Maybe String
    }

type Msg
    = Login
    | GotNewSession (Result Http.Error ())
    | InputEmail String
    | InputPassword String

encodeCredentials : Model -> JE.Value
encodeCredentials credentials =
    JE.object
        [ ( "email", JE.string credentials.email )
        , ( "password", JE.string credentials.password )
        ]



getNewSession : Model -> Cmd Msg
getNewSession model =
  Http.riskyRequest
    { url = endpoint ++ "/get_new_session"
    , method = "post"
    , headers = []
    , body = Http.jsonBody (encodeCredentials model)
    , timeout = Nothing
    , tracker = Nothing
    , expect = Http.expectWhatever GotNewSession
    }

init : () -> (Model, Cmd Msg)
init _ =
    ({ email = ""
    , password = ""
    , error = Nothing
    }
    , Cmd.none
    )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Login ->
            (model, getNewSession model)
        GotNewSession result ->
            case result of
                Ok _ ->
                    (model, Nav.load "app/")
                Err err ->
                    ({ model | error = Just (httpErrorDecode err) }, Cmd.none)
        InputEmail email ->
            ({model | email = email}, Cmd.none)
        InputPassword password ->
            ({model | password = password}, Cmd.none)


view : Model -> Html Msg
view model =
   form []
    [ h2 [] [ text "Training" ]
    , input
        [ placeholder "email"
        , type_ "email"
        , onInput InputEmail
        , value model.email
        ] []
    , input
        [ placeholder "password"
        , type_ "password"
        , onInput InputPassword
        , value model.password
        ] []
    , button [ onClick Login ] [ text "Login" ]
    ]



