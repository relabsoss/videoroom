-module(wa_app).
-behaviour(application).

-export([
        start/2, 
        stop/1,
        priv_dir/0, 
        priv/1
    ]).

-include("wa.hrl").

start(_StartType, _StartArgs) ->
  Routes = [
      {"/control", handler_control, []},
      {"/", cowboy_static, {file,  filename:join([priv_dir(), "index.html"])}},
      {"/[...]", cowboy_static, {dir, priv_dir()}}
    ],
  Dispatch = cowboy_router:compile([{'_',  Routes}]),
  cowboy:start_clear(wa_http_listener, 
                    [
                      {ip, {127,0,0,1}}, 
                      {port, 8081}
                    ],
                    #{ env => #{ dispatch => Dispatch }}),
  wa_sup:start_link().

stop(_State) ->
  ok.

root_dir() ->
  Ebin = filename:dirname(code:which(?MODULE)),
  filename:dirname(Ebin).

priv_dir() ->
  filename:join(root_dir(), "priv").
