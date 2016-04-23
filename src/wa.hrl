%
% Common project options
%

-define(AFTER(Timeout, Event), {ok, _} = timer:send_after(Timeout, Event)).
-define(ASYNC(F), proc_lib:spawn(fun() -> F end)).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 50, Type, [I]}).
-define(CHILD(I, Type, Param), {I, {I, start_link, Param}, permanent, 50, Type, [I]}).
-define(CHILD(Id, I, Type, Param), {Id, {I, start_link, Param}, permanent, 50, Type, [I]}).

%
% Logger
%

-define(ERROR(Msg), lager:error(Msg, [])).
-define(ERROR(Msg, Params), lager:error(Msg, Params)).
-define(INFO(Msg), lager:info(Msg, [])).
-define(INFO(Msg, Params), lager:info(Msg, Params)).
-define(WARNING(Msg), lager:warning(Msg, [])).
-define(WARNING(Msg, Params), lager:warning(Msg, Params)).
-define(DEBUG(Msg), lager:debug(Msg, [])).
-define(DEBUG(Msg, Params), lager:debug(Msg, Params)).

%
% Pub/Sub
%

-define(ME(Reg), gproc:reg({n, l, Reg})).
-define(LOOKUP(Reg), gproc:lookup_pid({n, l, Reg})).
-define(LOOKUPS(Reg), gproc:lookup_pids({n, l, Reg})).
-define(PUB(Event, Msg), pubsub:pub(Event, Msg)).
-define(SUB(Event), pubsub:sub(Event)).
-define(UNSUB(Event), pubsub:unsub(Event)).
-define(LOOKUP_SUB(Reg), gproc:lookup_pids({p, l, Reg})).

%
% Params
%

-define(STEP, 1000).
