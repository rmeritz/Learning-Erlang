-module(sequential).
-export([sum/1, create/1, reverse_create/1, print_create/1, print_even/1]).
-export([filter/2,reverse/1, concatenate/1, flatten/1]).

sum(0) -> 
    0;
sum(N) when is_integer(N), N > 0 ->
    N + sum(N-1). 

reverse_create(0) -> 
    [];
reverse_create(N) when is_integer(N), N > 0 ->
    [N | reverse_create(N-1)].

create(N) -> 
    lists:reverse(reverse_create(N)).

print_create(0) -> 
    io:format("");
print_create(N) when is_integer(N), N > 0 ->
    io:format("Number:~p~n", [N]),
    print_create(N-1).

print_even(0) ->
    io:format("");
print_even(N) when is_integer(N), N > 0, N rem 2 == 1 -> 
    print_even(N-1);
print_even(N) when is_integer(N), N > 0, N rem 2 == 0 ->
    io:format("Number:~p~n", [N]),
    print_even(N-1).

filter([H|T], N) when is_integer(N), is_integer(H), N >= H ->
    [H | filter(T, N)];
filter([_|T], N) ->
    filter(T, N);
filter([],_) ->
    [].

reverse(L) -> 
    reverse(L, []).

reverse([H|T], L) ->
    reverse(T, [H|L]);
reverse([], ReversedList) ->
    ReversedList.
    
concatenate([]) ->
    [];
concatenate([H|T]) ->
    concatenate(H,T,[]).

concatenate([H|T],Rest,Buffer) ->
    concatenate(T,Rest,[H|Buffer]);
concatenate([],[H|T],Buffer) ->
    concatenate(H,T,Buffer);
concatenate([],[],Buffer) ->
    reverse(Buffer).

flatten([]) ->
    [];
flatten([H|T]) when is_list(H)->
    concatenate([flatten(H), flatten(T)]);
flatten([H|T]) ->
    ([H|flatten(T)]).
