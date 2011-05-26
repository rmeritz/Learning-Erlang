-module(mutex).
-export([start/0,wait/0,signal/0]).

-export([free/0, busy/0, call/1]).

start() ->
    register(mutex, spawn(mutex, free, [])),
    ok.  

free() ->
    receive
	{Pid, wait} ->
	    Pid ! {reply, ok},
	    io:format("~p made mutex change from free to busy~n", [Pid]),
	    busy()
    end.

busy() ->
    receive
	{Pid, signal} ->
	    Pid ! {reply, ok},
	    io:format("~p made mutex change from busy to free~n", [Pid]),
	    free()
    end. 

call(Msg) ->
    mutex ! {self(), Msg}, 
    receive 
	{reply, Reply} ->
	    Reply
    end.

wait() ->
    spawn(mutex, call, [wait]),
    ok.

signal() ->
    spawn(mutex, call, [signal]),
    ok.
