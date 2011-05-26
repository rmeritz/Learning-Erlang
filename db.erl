-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).

new() -> 
    [].

destroy(_Db) ->
    ok.

write(Key, Element, Db) ->
    [{Key, Element} | Db].

delete(_, []) -> 
    [];
delete(Key, [{Key,_}| T]) ->
    T;
delete(Key, [H|T]) ->
    [H | delete(Key, T)].

read(_Key, []) ->
    {error, instance};
read(Key, [{Key, Element}|_]) ->
    {ok, Element};
read(Key, [_|T]) ->
    read(Key, T).

match(Element, [{Key, Element}|T]) ->
    [Key | match(Element, T)];
match(Element, [_,T]) ->
    match(Element, T);
match(_Element, []) ->
    []. 
