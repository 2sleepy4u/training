module Main exposing (..)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Pages.Login as Login
import Pages.Plan as Plan
import Pages.DailyList as Daily exposing (..)


type Page
    = LoginPage (Login.Model, Cmd Login.Msg)
    | DailyPage (Daily.Model, Cmd Daily.Msg)
    | PlanPage (Plan.Model, Cmd Plan.Msg)
    | NotFound


type Msg
  = LoginMsg Login.Msg
  | DailyMsg Daily.Msg
  | PlanMsg Plan.Msg
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
            LoginPage loginPage ->
                let
                    ( loginModel, _) =  loginPage
                    ( newSubModel, cmd ) = Login.update loginMsg loginModel
                in
                ( {model | page = LoginPage (newSubModel, Cmd.none)}, Cmd.map LoginMsg cmd)
            _ ->
                ( model, Cmd.none )
    DailyMsg dailyMsg ->
        case model.page of
            DailyPage dailyPage ->
                let
                    ( dailyModel, _) = dailyPage
                    ( newSubModel, cmd ) = Daily.update dailyMsg dailyModel
                in
                ( {model | page = DailyPage (newSubModel, Cmd.none)}, Cmd.map DailyMsg cmd)
            _ ->
                ( model, Cmd.none )
    PlanMsg subMsg ->
        case model.page of
            PlanPage page ->
                let
                    ( subModel, _) = page
                    ( newSubModel, cmd ) = Plan.update subMsg subModel 
                in
                ( {model | page = PlanPage (newSubModel, Cmd.none)}, Cmd.map PlanMsg cmd)
            _ ->
                ( model, Cmd.none )




view : Model -> Browser.Document Msg
view model =
  { title = "URL Interceptor"
  , body =
      case model.page of
          LoginPage login ->
              [ Login.view (Tuple.first login) |> Html.map LoginMsg ]
          DailyPage daily ->
              [ Daily.view (Tuple.first daily) |> Html.map DailyMsg ]
          PlanPage plan ->
              [ Plan.view (Tuple.first plan) |> Html.map PlanMsg ]
          NotFound ->
              [
              div [ classList [("error", True)]] [ text "404 Not found" ],
              a [ 
                  classList [("btnReturn", True)],
                  href "/" 
                ] [ text "Return home"]
              ]

  }


pathResolve : Model -> String -> ( Model, Cmd Msg )
pathResolve model path =
    case path of
        "/login" ->
            let 
                (subModel, cmd) = Login.init ()
            in
            ({model | page = LoginPage (subModel, cmd) } , Cmd.map LoginMsg cmd)
        "/" ->
            let 
                (dailyModel, cmd) = Daily.init ()
            in
            ({model | page = DailyPage (dailyModel, cmd) } , Cmd.map DailyMsg cmd)
        "/addPlan" -> 
            let 
                (subModel, cmd) = Plan.init ()
            in
            ({model | page = PlanPage (subModel, cmd) } , Cmd.map PlanMsg cmd)

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



