-module(my_db).
-export([start/0,stop/0,write/2,delete/1,read/1,match/1]).

-export([init/0]).

start() ->
    register(db_server, spawn(my_db, init, [])).

init() ->
    DB = db:new(),
    loop(DB).

stop() ->
    call(destroy).

write(Key, Element) ->
    call({write, Key, Element}).

delete(Key) ->
    call({delete, Key}).

read(Key) ->
    call({read, Key}).

match(Element) ->
    call({match, Element}).

call(Msg) ->
    db_server ! {request, self(), Msg}, 
    receive
	{reply, Reply} ->
	    Reply
    end.

reply(Pid, Msg) ->
    Pid ! {reply, Msg}.

loop(DB) ->
    receive
	{request, Pid, destroy} ->
	    db:destory(DB),
	    reply(Pid, ok);
	{request, Pid, {write, Key, Element}}  ->
	    NewDB = db:write(Key, Element, DB),
	    reply(Pid, ok),
	    loop(NewDB);
	{request, Pid, {delete, Key}} ->
	    NewDB = db:delete(Key, DB),
	    reply(Pid, ok),
	    loop(NewDB);
	{request, Pid, {read, Key}} ->
	    Reply = db:read(Key, DB), 
	    reply(Pid, Reply),
	    loop(DB);
	{request, Pid, {match, Element}} ->
	    Reply = db:match(Element, DB),
	    reply(Pid, Reply), 
	    loop(DB)
    end.
