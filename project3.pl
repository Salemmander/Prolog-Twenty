%:- ['base.pl'].
% Example AI that simply draws cards
example_ai_1(game_state(no_error,_,_,_,_), play(drawcard,empty)).

% Example AI that will only play a card if the count can be made with 1 card.
example_ai_2(game_state(no_error,Count,_,_,PState), play(Play,empty)) :-
	pstate(hand,PState,Hand), example_ai_2_rec(Count,Hand,Play).

example_ai_2_rec(_,[],drawcard).
example_ai_2_rec(Count,[Card|_],[wild(Card,Count)]) :- face(Card, k).
example_ai_2_rec(Count,[Card|_],[Card]) :- value(Card,Count).
example_ai_2_rec(Count,[Card|Hand],Play) :- value(Card,V), V\=Count, example_ai_2_rec(Count,Hand,Play).


 
project_ai_1(game_state(no_error,Count,_,_,PState), play(Play,empty)):-
	pstate(hand,PState, Hand),
	combinations(Hand,Combos),
	possible_plays(Combos,Count,Possible_Plays),
	most_cards(Possible_Plays, Valid_Plays),
	fewest_kings(Valid_Plays, Plays),
	project_ai(Plays, Count, Play).

project_ai([],_,drawcard).
project_ai([Play|_],_,Play):-
    \+ has_king(Play).
project_ai([Play|_],Count,SetPlay):-
    has_king(Play),
    set_kings(Play,Count,SetPlay).

project_ai_2(game_state(no_error,Count,_,_,PState), play(Play,empty)):-
	pstate(hand,PState, Hand),
	combinations(Hand,Combos),
	possible_plays(Combos,Count,Possible_Plays),
    highest_penalty(Possible_Plays,Plays),
	project_ai(Plays, Count, Play).


% Set the first king to the count remainder - (king count - 1) and then set the other kings to 1
set_kings(Play,Count,SetPlay):-
    sum_list(Play,Sum_No_Kings),
    Remainder is Count - Sum_No_Kings,
    king_count(Play,King_Count),
    FirstKing is Remainder - (King_Count - 1),
    make_wilds(Play,FirstKing,SetPlay).

make_wilds([], _, []).
make_wilds([card(Suit,k)|T], Value, [wild(card(Suit,k),Value)|Rest]) :-
    set_wilds(T, 1, Rest).
make_wilds([Card|T], Value, [Card|Rest]) :-
    Card \= card(_,k),
    make_wilds(T, Value, Rest).

set_wilds([], _, []).
set_wilds([card(Suit,k)|T], Value, [wild(card(Suit,k),Value)|Rest]) :-
    set_wilds(T, 1, Rest).
set_wilds([Card|T], Value, [Card|Rest]) :-
    Card \= card(_,k),
    set_wilds(T, Value, Rest).

king_count([], Count) :-
    Count is 0.

king_count([card(_,k)|Rest], Count) :-
    king_count(Rest, RestCount),
    Count is RestCount + 1.

king_count([Card|Rest], Count) :-
    Card \= card(_,k),
    king_count(Rest, Count).

possible_plays(Combos, Count, Plays) :-
    findall(List, (member(List, Combos), has_king(List), sum_list(List,Sum),king_count(List,KCount), Sum < Count - KCount), Plays1),
    findall(List, (member(List, Combos), \+ has_king(List), sum_list(List,Sum), Sum = Count), Plays2),
    append(Plays1, Plays2, Plays).
    
highest_penalty(Possible_Plays, Plays) :-
    findall(Play, (member(Play, Possible_Plays), sum_penalty(Play, Max_Penalty),
    \+ (member(Possible_Play, Possible_Plays), sum_penalty(Possible_Play, Penalty), Penalty > Max_Penalty)), Plays).

has_king(List) :-
    member(card(_, k), List).

sum_list([], 0).
sum_list([Card|Cards], Sum) :-
    (value(Card, wild) -> sum_list(Cards, Sum);
    value(Card, Value),
    sum_list(Cards, RestSum),
    Sum is Value + RestSum).

sum_penalty([], 0).
sum_penalty([Card|Cards], Sum) :-
    pvalue(Card, Value),
    sum_penalty(Cards, RestSum),
    Sum is Value + RestSum.

most_cards(Lists, LongestLists) :-
    findall(LongestList, (member(LongestList, Lists), length(LongestList, MaxLength),
    \+ (member(List, Lists), length(List, Length), Length > MaxLength)), LongestLists).

fewest_kings([],[]).
fewest_kings(Lists, FewestLists) :-
    maplist(count_value(), Lists, Counts),
    min_list(Counts, MinCount),
    include(has_count(MinCount), Lists, FewestLists).

count_value(List, Count) :-
    include(=(card(_,k)), List, ValueOccurrences),
    length(ValueOccurrences, Count).

has_count(Count, List) :-
    count_value(List, Count).




% Test Your code
player1(GameState, Play) :- project_ai_1(GameState,Play).
player2(GameState, Play) :- project_ai_2(GameState,Play).

%player1(GameState, Play) :- user_interface(GameState,Play).
%player2(GameState, Play) :- project_ai_2(GameState,Play).

%player1(GameState, Play) :- project_ai_1(GameState,Play).
%player2(GameState, Play) :- project_ai_2(GameState,Play).


%player1(GameState, Play) :- example_ai_1(GameState,Play).
%player2(GameState, Play) :- example_ai_2(GameState,Play).
