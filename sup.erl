-module(sup).
-export([start/1, start_child/4, stop/1]).

-export([loop/1, init/0]).

-export([test/0]).

start(SupName) ->
    register(SupName, spawn(sup, init, [])),
    Pid = whereis(SupName),
    {ok, Pid}. 

init() ->
    process_flag(trap_exit, true),
    loop([]).

start_child(Sup, Mod, Func, Args) ->
    Sup ! {start, self(), Mod, Func, Args},
    receive
	{started, Pid} ->
	    {ok, Pid}
    end.

stop(Sup) ->
    Sup ! stop,
    ok.

loop(ProcessList) ->
    receive
	{start, From, Mod, Func, Args} ->
	    Pid = spawn_link(Mod, Func, Args),
	    NewProcessList = addChild(ProcessList,Pid, Mod, Func, Args, 0),
	    From ! {started, Pid},
	    io:format("Started process ~p with ~p:~p(~p)~n", [Pid, Mod, Func, Args]), 
	    io:format("ProcessList:~p~n", [NewProcessList]),
	    loop(NewProcessList);
	stop ->
	    io:format("System Stopped~n"),
	    ok;
	{'EXIT', Pid, Reason} ->
	    Child = toRestartChild(ProcessList, Pid),
            NewProcessList = case Child of
				 {true,{child,{M,F,A,C}}} ->
				     NewPid = spawn_link(M,F,A), 
				     io:format("===========================================================~n Error: Process ~p Terminated ~p time(s) ~n\tReason for termination:~p~n\tRestarting with ~p:~p~n============================================================~n",[Pid, C+1 , Reason, M, F]), 
				     PL = removeChild(ProcessList, Pid), 	     
				     addChild(PL, NewPid, M, F, A, C+1);
				 {false, notChild} ->
				     io:format("Recieved exit signal from ~p~nWas not child~nNo action was taken by the system~n",[Pid]),
				     ProcessList;
				 {false, child} ->
				     io:format("===========================================================~nError: Process ~p Terminated 5 time(s) ~n\tReason for termination:~p~n\tCrashed to many times will not restart~n============================================================~n",[Pid, Reason]),
				     removeChild(ProcessList, Pid)  		     
			     end,
	    io:format("ProcessList:~p~n", [NewProcessList]),
	    loop(NewProcessList)
    end.

addChild(ProcessList, Pid, Mod, Func, Args, Count) -> 
    [{Pid, Mod, Func, Args, Count} | ProcessList].

removeChild(L, Pid) ->
    removeChild(L, [], Pid).

removeChild([{Pid, _,_,_,_}|T], Buffer, Pid) ->
    T++Buffer;
removeChild([H|T], Buffer, Pid) ->
    removeChild(T, [H|Buffer], Pid);
removeChild([], Buffer,_) ->
    Buffer. 

toRestartChild([], _) ->
    {false,notChild}; 
toRestartChild([{Pid, M,F,A,Count}|_], Pid) when Count < 6 ->
    {true,{child,{M,F,A,Count}}};
toRestartChild([{Pid,_,_,_,_}|_], Pid) ->    
    {false,child};
toRestartChild([_|T], Pid) ->
    toRestartChild(T,Pid).

test() ->
    {ok, SupPid} = start(sup),
    start_child(sup, timer, sleep, [10000]),
    start_child(SupPid, timer, sleep, [1000]),
    start_child(sup, timer, sleep, [5000]),
    start_child(sup, timer, sleep, [100]),
    exit(SupPid, notchild),
    start_child(sup, timer, sleep, [1000]),
    timer:sleep(100000),
    stop(sup).		
