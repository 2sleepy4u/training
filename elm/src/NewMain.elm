module NewMain exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Pages.Login as Login


type Page
    = LoginPage Login.Model
    | NotFound


type Msg
  = LoginMsg Login.Msg
  -- URL
  | UrlChanged Url.Url
  | LinkClicked Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    UrlChanged url ->
        pathResolve model url.path
    LinkClicked urlRequest ->
        case urlRequest of
            Browser.Internal url ->
                ( model, Nav.pushUrl model.key (Url.toString url) )
            Browser.External href ->
                ( model, Nav.load href )
    LoginMsg loginMsg ->
        case model.page of
            LoginPage loginModel ->
                let
                    ( newSubModel, cmd ) = Login.update loginMsg loginModel
                in
                ( {model | page = LoginPage newSubModel}, Cmd.map LoginMsg cmd)
            _ ->
                ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
  { title = "URL Interceptor"
  , body =
      case model.page of
          LoginPage loginModel ->
              [ Login.view loginModel |> Html.map LoginMsg ]
          NotFound -> 
              [
              div [] [ text "Not found" ],
              a [ href "/login" ] [ text "Return home"]
              ]

  }


pathResolve : Model -> String -> ( Model, Cmd Msg )
pathResolve model path = 
    case path of 
        "/login" ->
            ({model | page = LoginPage { email = "" , password = "" , error = Nothing }} , Cmd.none)
        _ -> 
            ({ model | page = NotFound }, Cmd.none)



type alias Model =
    { key: Nav.Key
    , url: Url.Url
    , page: Page
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    update (UrlChanged url) {key = key, url = url, page = NotFound }
  --( {key = key, url = url, page = NotFound }, Cmd.none )



subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none



main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }



