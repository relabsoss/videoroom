-module(wa_sup).
-behaviour(supervisor).
-export([
          start_link/0,
          init/1
        ]).

-include("wa.hrl").


start_link() ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
  ?LOG_INFO("modules ~p", [?CONFIG(modules, [])]),
  Modules = lists:flatten([apply(M) || M <- ?CONFIG(modules, [])]),
  {ok, {{one_for_one, 500, 10000}, Modules}}.

apply({sup, Module}) ->
  ?CHILD(Module, supervisor);
apply({Module, ConfigName}) ->
  ?CHILD(Module, worker, [ConfigName]);
apply(Module) ->
  ?CHILD(Module, worker).
