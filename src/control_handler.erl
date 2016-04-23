%% -*- coding: utf-8 -*-
-module(control_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3, websocket_init/3, websocket_handle/3, websocket_info/3, websocket_terminate/3]).

-include("wa.hrl").

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    {ok, Req, undefined}.

websocket_handle({text, Msg}, Req, State) ->
    DMsg = inout:in(Msg),
    ?INFO("Income ~p", [DMsg]),
    NewState = process(DMsg, State),
    {ok, Req, NewState};
websocket_handle(Data, Req, State) ->
    ?INFO("Unknoun message ~p", [Data]),
    {ok, Req, State}.

websocket_info({whoareyou, Pid}, Req, State) ->
    Pid ! {send, #{ op => <<"here">>, user => State }},
    {ok, Req, State};
websocket_info({send, Msg}, Req, State) ->
    EMsg = inout:out(Msg),
    ?INFO("Send message ~p", [EMsg]),
    {reply, {text, EMsg}, Req, State};
websocket_info(Info, Req, State) ->
    ?INFO("Unknown message ~p", [Info]),
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, #{ name := _, id := _ } = State) ->
    ?PUB(users, {send, #{ op => <<"leave">>, user => State }}),
    ok;
websocket_terminate(_Reason, _Req, _State) ->
    ok.

%
% local
%

process(#{ <<"op">> := <<"hereiam">>, <<"name">> := Name }, undefined) ->
    Token = inout:token(),
    ?INFO("Token ~p", [Token]),
    State = #{ name => Name, id => Token },
    ?SUB({user, Token}),
    ?PUB(users, {whoareyou, self()}),
    ?PUB(users, {send, #{ op => <<"enter">>, user => State }}),
    ?SUB(users),
    State;

process(#{ <<"op">> := <<"send">>, <<"to">> := To, <<"m">> := M }, #{ name := _, id := _ } = State) ->
    ?PUB({user, To}, {send, #{ op => <<"send">>, from => State, m => M }}),
    State;

process(#{ <<"op">> := <<"pub">>, <<"m">> := M }, #{ name := _, id := _ } = State) ->
    ?PUB(users, {send, #{ op => <<"pub">>, from => State, m => M }}),
    State;

process(Msg, State) ->
    ?INFO("Unknown message ~p", [Msg]),
    State.

