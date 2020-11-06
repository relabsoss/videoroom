-module(handler_control).
-export([
          init/2, 
          websocket_init/1, 
          websocket_handle/2, 
          websocket_info/2,
          terminate/3
        ]).

-include("wa.hrl").


init(Req, State) ->
  {cowboy_websocket, Req, State}.

websocket_init(State) ->
  {ok, undefined}.

websocket_handle({text, Msg}, State) ->
  process(?FROM_JSON(Msg), State);
websocket_handle({pong, _}, State) ->
  {ok, State};
websocket_handle(Data, State) ->
  ?LOG_INFO("Unknown data handled: ~p", [Data]),
  {ok, State}.

websocket_info({whoareyou, Pid}, State) ->
  Pid ! {send, #{ op => <<"here">>, user => State }},
  {ok, State};
websocket_info({send, Msg}, State) ->
  {reply, {text, ?TO_JSON(Msg)}, State};
websocket_info(Info, State) ->
  ?LOG_INFO("Unknown info handled: ~p", [Info]),
  {ok, State}.

terminate(_Reason, _PartialReq, #{ name := _, id := _ } = State) -> 
  ?PUB(users, {send, #{ op => <<"leave">>, user => State }}),
  ok;
terminate(_Reason, _PartialReq, _State) -> 
  ok. 

%
% processing
%

process(#{ <<"op">> := <<"hereiam">>, <<"name">> := Name }, undefined) ->
  Token = utils:hash(Name),
  State = #{ name => Name, id => Token },
  ?SUB({user, Token}),
  ?PUB(users, {whoareyou, self()}),
  ?PUB(users, {send, #{ op => <<"enter">>, user => State }}),
  ?SUB(users),
  {ok, State};

process(#{ <<"op">> := <<"send">>, <<"to">> := To, <<"m">> := M }, #{ name := _, id := _ } = State) ->
  ?PUB({user, To}, {send, #{ op => <<"send">>, from => State, m => M }}),
  {ok, State};

process(#{ <<"op">> := <<"pub">>, <<"m">> := M }, #{ name := _, id := _ } = State) ->
  ?PUB(users, {send, #{ op => <<"pub">>, from => State, m => M }}),
  {ok, State};

process(Msg, State) -> 
  ?LOG_INFO("Unknown message ~p > ~p", [State, Msg]), 
  {ok, State}. 
