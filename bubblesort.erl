-module(bubblesort).
-export([bubblesort/1]).

bubblesort(L) ->
    bubblesort(L,[],false).

bubblesort([],B,true) ->
    bubblesort(lists:reverse(B),[],false);
bubblesort([],B,false) ->
    lists:reverse(B);
bubblesort([OneElement],Buffer,Bool) ->
    bubblesort([],[OneElement|Buffer],Bool);
bubblesort([First,Second|Rest],Buffer,_) when First > Second ->
    bubblesort([First|Rest],[Second|Buffer],true);
bubblesort([First,Second|Rest],Buffer,Bool) when First =< Second ->
    bubblesort([Second|Rest],[First|Buffer],Bool).
