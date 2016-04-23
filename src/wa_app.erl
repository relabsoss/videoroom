-module(wa_app).
-behaviour(application).

-export([start/2, stop/1]).

-include("wa.hrl").

start(_StartType, _StartArgs) ->
    VRoutes = [
            {"/", cowboy_static, {file, "priv/index.html"}},
            {"/static/[...]", cowboy_static, {dir, static_dir()}},
            {"/control", control_handler, []}
        ],
    Dispatch = cowboy_router:compile([{'_',  VRoutes}]),
    cowboy:start_http(webapp_http_listener, 5, 
                      [{port, 8080}],
                      [{env, [{dispatch, Dispatch}]}]).

stop(_State) ->
    ok.

priv_dir() ->
    Ebin = filename:dirname(code:which(?MODULE)),
    filename:join(filename:dirname(Ebin), "priv").

static_dir() ->
    filename:join([priv_dir(), "static"]).

