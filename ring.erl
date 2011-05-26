-module(ring).
%%Interface
-export([create/1,send/2,quit/0]).

-export([loop/1]).

create(N) when is_integer(N), N > 2 ->
    register(last, spawn(ring, loop, [first])),
    Pid = spawn(ring, loop, [last]),
    create_loop(N-2, Pid).

create_loop(1, Pid) ->
    register(first, spawn(ring, loop, [Pid])),
    ok;
create_loop(N, Pid) ->
    NewPid = spawn(ring, loop, [Pid]),
    create_loop(N-1, NewPid).

loop(ProcessToMsg) ->
    Last = whereis(last),
    receive
	stop when self() == Last ->
	    stopped;
	stop ->
	    ProcessToMsg ! stop,
	    io:format("Stop sent from ~p to ~p.~n", [self(), ProcessToMsg]);
	{_, 1} when self()==Last ->
	    loop(ProcessToMsg);
	{Msg, Loops} when self()==Last ->
	    ProcessToMsg ! {Msg, Loops-1},
	    io:format("~p sent from ~p to ~p.~n", [Msg, self(), ProcessToMsg]),
	    loop(ProcessToMsg);
	{Msg, Loops}  ->
	    ProcessToMsg ! {Msg, Loops},
	    io:format("~p sent from ~p to ~p.~n", [Msg, self(), ProcessToMsg]),	    
	    loop(ProcessToMsg)
    end.

send(Msg, Loops) when is_integer(Loops), Loops > 0 ->
    first ! {Msg, Loops},
    ok. 

quit() ->
    first ! stop,
    ok.



