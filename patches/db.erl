-module(db).
-export([new/0, destroy/1, write/3, delete/2, read/2, match/2]).
-export([code_upgrade/1]).

new() -> 
    ets:new(ets_table, []).

destroy(TableID) ->
    ets:delete(TableID),
    ok.

write(Key, Element, TableID) ->
    ets:insert(TableID, {Key, Element}),
    TableID.

delete(Key, TableID) ->
    ets:delete(TableID, Key).

read(Key, TableID) ->
    Value = ets:lookup(TableID, Key),
    case Value of
	[] ->
	    {error, instance};
	_->
	    Element = element(2, ((lists:nth(1, Value)))),
	    {ok, Element}
    end.

match(Element, TableID) ->
    Matches = ets:match(TableID, {'$1', Element}),
    lists:concat(Matches).


code_upgrade(RecordList) ->
    TableID = new(),
    list_to_table(RecordList, TableID),
    TableID.

list_to_table([{Key, Element}|T], TableID) ->
    write(Key, Element, TableID),
    list_to_table(T,TableID);
list_to_table([], _TableID) ->
    true. 

    
		    
    
