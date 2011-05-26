-module(reliablemutex).
%%Interface
-export([start/0,wait/0,signal/0]).

%%Test
-export([test/1]).

%%Spawned exports
-export([free/0]).

start() ->
    process_flag(trap_exit, true),
    register(mutex, spawn(mutex, free, [])),
    ok.  

free() ->
    receive
	{Pid, wait} ->
	    catch link(Pid),
	    Pid ! {reply, ok},
	    io:format("~p made mutex change from free to busy~n", [Pid]),
	    busy(Pid)
    end.

busy(Pid) ->
    receive
	{Pid, signal} ->
	    unlink(Pid),
	    Pid ! {reply, ok},
	    io:format("~p made mutex change from busy to free~n", [Pid]),
	    free();
	{'EXIT', Pid, _Reason} ->
	    io:format("~p died the reasource has been freed~n",[Pid]),
	    free()
       end. 

call(Msg) ->
    mutex ! {self(), Msg}, 
    receive 
	{reply, Reply} ->
	    Reply
    end.

wait() ->
    call(wait).

signal() ->
    call(signal).

test(Time) ->
    io:format("Waiting for reasource ~p~n", [self()]),
    reliablemutex:wait(),
    io:format("Using reasource ~p~n", [self()]),
    timer:sleep(Time),
    io:format("Releasing the reasource ~p~n", [self()]),
    reliablemutex:signal().
