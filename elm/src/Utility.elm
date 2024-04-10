module Utility exposing (..)
import Http

httpErrorDecode : Http.Error -> String
httpErrorDecode err = 
    case err of
        Http.BadUrl txt -> 
            txt
        Http.Timeout ->
            "Timeout"
        Http.NetworkError -> 
            "NetworkError"
        Http.BadStatus status ->
            "Status"
        Http.BadBody txt ->
            txt


