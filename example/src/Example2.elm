module Example2 exposing (..)

import Debug
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import Json.Decode as Decode
import Select


type alias Model =
    { id : String
    , characters : List Character
    , selectedCharacterId : Maybe String
    , selectState : Select.Model
    }


type alias Character =
    String


initialModel : String -> Model
initialModel id =
    { id = id
    , characters = []
    , selectedCharacterId = Nothing
    , selectState = Select.newState id
    }


initialCmds : Cmd Msg
initialCmds =
    fetch


type Msg
    = NoOp
    | OnSelect Character
    | SelectMsg (Select.Msg Character)
    | OnFetch (Result Http.Error (List Character))
    | OnQuery String


selectConfig : Select.Config Msg Character
selectConfig =
    Select.newConfig OnSelect identity
        |> Select.withInputClass "col-12"
        |> Select.withMenuClass "border border-gray"
        |> Select.withItemClass "border-bottom border-silver p1"
        |> Select.withCutoff 12
        |> Select.withOnQuery OnQuery


fetchUrl : String
fetchUrl =
    "http://swapi.co/api/people/?search=han"


fetch : Cmd Msg
fetch =
    Http.get fetchUrl resultDecoder
        |> Http.send OnFetch


resultDecoder : Decode.Decoder (List Character)
resultDecoder =
    Decode.at [ "results" ] collectionDecoder


collectionDecoder : Decode.Decoder (List Character)
collectionDecoder =
    Decode.list memberDecoder


memberDecoder : Decode.Decoder Character
memberDecoder =
    Decode.field "name" Decode.string


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        OnQuery query ->
            ( model, Cmd.none )

        OnFetch result ->
            case result of
                Ok characters ->
                    ( { model | characters = characters }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        OnSelect character ->
            ( { model | selectedCharacterId = Just character }, Cmd.none )

        SelectMsg subMsg ->
            let
                ( updated, cmd ) =
                    Select.update selectConfig subMsg model.selectState
            in
                ( { model | selectState = updated }, cmd )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        selecteCharacter =
            case model.selectedCharacterId of
                Nothing ->
                    Nothing

                Just id ->
                    model.characters
                        |> List.filter (\character -> character == id)
                        |> List.head
    in
        div [ class "bg-silver p1" ]
            [ text (toString model.selectedCharacterId)
            , h4 [] [ text "Pick an star wars character" ]
            , Html.map SelectMsg (Select.view selectConfig model.selectState model.characters selecteCharacter)
            ]
