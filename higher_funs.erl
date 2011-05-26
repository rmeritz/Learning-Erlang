-module(higher_funs).
-export([print_seq/1, smaller_list/2, print_evens/1, concat/1,sum/1]).

print_seq(N) ->
    lists:foreach(fun(X) -> io:format("~p~n",[X]) end, lists:seq(1,N)).

smaller_list(L,N) ->  
    lists:filter(fun(X) when N < X ->
			 false;
		    (_) ->
			 true
		 end, 
		 L).

print_list(L) ->
    lists:foreach(fun(X) ->
			  io:format("~p~n", [X])
		  end,
		  L).

evens(L) ->
    lists:filter(fun(X) when X rem 2 == 1 ->
			 false;
		    (_) ->
			 true
		 end,
		 L).

print_evens(L) ->
    print_list(evens(L)).

concat(LofL) ->
    lists:foldr(fun(X, Acc) ->
		       X++Acc
	       end,
	       [],LofL).

sum(L) ->
    lists:foldl(fun(X,Acc) ->
			X+Acc
		end,
		0,L).	
