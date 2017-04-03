module Main exposing (..)

import Html exposing (..)
import Dict exposing (Dict)
import Random
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


-- APP


main : Program Never Model Msg
main =
    Html.program { init = init, view = view, update = update, subscriptions = subscriptions }



-- MODEL


type alias Roller =
    { index : Int
    , die : Dict Int Int
    , rolls : List Int
    }


type alias Model =
    { currentIndex : Int
    , rollers : List Roller
    }


init : ( Model, Cmd Msg )
init =
    ( Model 0 [], Cmd.none )



-- UPDATE


type Msg
    = AddRoller
      -- Roll rollerIndex
    | Roll Int
      -- UpdateRolls rollerIndex rollValue
    | UpdateRolls Int Int
      -- AddDie rollerIndex nFaces
    | AddDie Int Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddRoller ->
            ( { model | currentIndex = model.currentIndex + 1, rollers = (Roller model.currentIndex Dict.empty []) :: model.rollers }, Cmd.none )

        AddDie rollerIndex nFaces ->
            ( { model | rollers = addDie rollerIndex nFaces model.rollers }, Cmd.none )

        Roll rollerIndex ->
            ( model, Random.generate (UpdateRolls rollerIndex) (getRollValue rollerIndex model.rollers) )

        UpdateRolls rollerIndex rollValue ->
            ( { model | rollers = addRolls rollerIndex rollValue model.rollers }, Cmd.none )



-- add die


addDie : Int -> Int -> List Roller -> List Roller
addDie rollerIndex nFaces rollers =
    List.map (addDieToRoller rollerIndex nFaces) rollers


addDieToRoller : Int -> Int -> Roller -> Roller
addDieToRoller rollerIndex nFaces roller =
    if rollerIndex == roller.index then
        { roller | die = Dict.update nFaces updateDie roller.die }
    else
        roller


updateDie : Maybe Int -> Maybe Int
updateDie current =
    case current of
        Just i ->
            Just (i + 1)

        Nothing ->
            Just 1



-- roll


getRollValue : Int -> List Roller -> Random.Generator Int
getRollValue rollerIndex rollers =
    findDieDict rollerIndex rollers
        |> getDieList
        |> List.map (\n -> Random.int 1 n)
        |> List.foldl addGenerators (Random.int 0 0)


addGenerators : Random.Generator Int -> Random.Generator Int -> Random.Generator Int
addGenerators genA genB =
    Random.map2 (+) genA genB


findDieDict : Int -> List Roller -> Dict Int Int
findDieDict rollerIndex rollers =
    case rollers of
        roller :: rest ->
            if rollerIndex == roller.index then
                roller.die
            else
                findDieDict rollerIndex rest

        [] ->
            Dict.empty


getDieList : Dict Int Int -> List Int
getDieList dieDict =
    List.concat (List.map dieDictValueToDieList (Dict.toList dieDict))


dieDictValueToDieList : ( Int, Int ) -> List Int
dieDictValueToDieList ( nFaces, count ) =
    List.repeat count nFaces



-- add rolls


addRolls : Int -> Int -> List Roller -> List Roller
addRolls rollerIndex rollValue rollers =
    List.map (addRollsToRoller rollerIndex rollValue) rollers


addRollsToRoller : Int -> Int -> Roller -> Roller
addRollsToRoller rollerIndex rollValue roller =
    if rollerIndex == roller.index then
        { roller | rolls = rollValue :: roller.rolls }
    else
        roller



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW
-- Html is defined as: elem [ attribs ][ children ]
-- CSS can be applied via class names or inline style attrib


maybeIntToString : Maybe Int -> String
maybeIntToString latestRoll =
    case latestRoll of
        Just i ->
            toString i

        Nothing ->
            "0"


maybeIntsToString : Maybe (List Int) -> List String
maybeIntsToString rollList =
    case rollList of
        Just rolls ->
            List.map toString rolls

        Nothing ->
            []


dieView : Roller -> Int -> Html Msg
dieView roller nFaces =
    div [ class "die-selector" ]
        [ text (maybeIntToString (Dict.get nFaces roller.die))
        , button [ onClick (AddDie roller.index nFaces) ] [ text ("+" ++ (toString nFaces)) ]
        ]


rollerView : Roller -> Html Msg
rollerView roller =
    div [ class "roller" ]
        [ div [ class "latest-roll" ] [ text (maybeIntToString (List.head roller.rolls)) ]
        , div [ class "roll-history" ] (List.map (\s -> div [] [ text s ]) (maybeIntsToString (List.tail roller.rolls)))
        , dieView roller 20
        , dieView roller 12
        , dieView roller 10
        , dieView roller 8
        , dieView roller 6
        , dieView roller 4
        , button [ onClick (Roll roller.index) ] [ text "Roll" ]
        ]


view : Model -> Html Msg
view model =
    div [ class "main", style styles.main ]
        [ div [] (List.map rollerView model.rollers)
        , button [ onClick AddRoller ] [ text "Add Roller" ]
        ]



-- CSS STYLES


styles : { img : List ( String, String ), main : List ( String, String ) }
styles =
    { img =
        [ ( "width", "33%" )
        , ( "border", "4px solid #337AB7" )
        ]
    , main =
        [ ( "background", "#333333" ), ( "color", "#eeeeee" ) ]
    }
