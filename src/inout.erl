%% -*- coding: utf-8 -*-
-module(inout).

-export([in/1, in/2, out/1, token/0]).

-include("wa.hrl").

in(Msg) ->
    in(Msg, #{}).

in(Msg, Default) ->
    try jsx:decode(Msg, [return_maps]) of
        {error, Error} -> 
            ?ERROR("Error ~p in decoding ~p", [Error, Msg]),
            Default;
        {error, Error, Str} -> 
            ?ERROR("Error ~p in decoding ~p", [Error, Str]),
            Default;
        Data -> Data
    catch Exc:Exp -> 
        ?ERROR("Exception ~p:~p in decoding of ~p", [Exc, Exp, Msg]),
        Default 
    end.

out(Msg) ->
    try
        case jsx:encode(Msg) of
            Str when is_binary(Str) -> Str;
            Err -> 
                ?ERROR("Error encoding to JSON ~p in ~p", [Err, Msg]), 
                jsx:encode([])
        end
    catch 
        Exc:Exp -> 
            ?ERROR("Exception ~p:~p in encoding of ~p", [Exc, Exp, Msg]),
            <<"{}">>
    end.

token() -> list_to_binary(random_str(32)).
random_str(Length) ->
    Alpha = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM",
    Size = length(Alpha),
    [lists:nth(crypto:rand_uniform(1, Size + 1), Alpha) || _ <- lists:seq(1, Length)].

