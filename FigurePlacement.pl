:- use_module(library(lists)).

list_length([], 0).
list_length([_|T], L) :- list_length(T, L1), L is L1+1.

list_comparison([], []).
list_comparison(List_1, [H1|T1]) :-
    delete(List_1, H1, Result),
    not(List_1 = Result),
    list_comparison(Result, T1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wrapper
find_figure_max_min(Figure, X_max, X_min, Y_max, Y_min) :- 
    find_figure_X_max_min(Figure, X_max, X_min),
    find_figure_Y_max_min(Figure, Y_max, Y_min), !.
% realization
find_figure_X_max_min([[X, _]], X, X).
find_figure_X_max_min([[X1, _], [X2, _]|Tail], X_maximum, X_minimum) :- 
    find_figure_X_max_min([[X2, _]|Tail], Maximum, Minimum),
    comparison(>, X1, Maximum, X_maximum),
    comparison(<, X1, Minimum, X_minimum).
% realization
find_figure_Y_max_min([[_, Y]], Y, Y).
find_figure_Y_max_min([[_, Y1], [_, Y2]|Tail], Y_maximum, Y_minimum) :- 
    find_figure_Y_max_min([[_, Y2]|Tail], Maximum, Minimum),
    comparison(>, Y1, Maximum, Y_maximum),
    comparison(<, Y1, Minimum, Y_minimum).

comparison(Operation, X, Y, X) :- compare(Operation, X, Y), !.
comparison(_, _, Y, Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wrapper
find_figure_center(Figure, Center) :-
    list_length(Figure, Count),
    find_figure_center(Figure, Center, [0, 0], Count), !.
% realization
find_figure_center([], [X2, Y2], [X1, Y1], Count) :-
    X2 is X1/Count,
    Y2 is Y1/Count.
find_figure_center([[X1, Y1]|Tail], Center, [X2, Y2], Count) :-
    X3 is X1+X2, 
    Y3 is Y1+Y2,
    find_figure_center(Tail, Center, [X3, Y3], Count).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_figures(List_of_figures, End) :-
    get_figures(1, End, List_of_figures), !.

get_figures(End, End, _).
get_figures(Start, End, [Head|Tail]) :-
    figure(Head, Start),
    N is Start+1,
    get_figures(N, End, Tail).
get_figures(Start, End, Figure) :-
    N is Start+1,
    get_figures(N, End, Figure).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_fact_figures(List) :-
    findall((Figure, Count), figure(Figure, Count), List).


get_fact_figure_dublicates([], []).
get_fact_figure_dublicates([H1|T1], [H2|T2]) :-
    get_fact_dublicates(H1, T1, H2),
    get_fact_figure_dublicates(T1, T2).
    
get_fact_dublicates(_, [], []).
get_fact_dublicates(_, [], _).
get_fact_dublicates((Figure, N1), [(H, N2)|T], H) :-
    list_comparison(Figure, H),
    N1 = N2,
    get_fact_dublicates(Figure, T, H).
get_fact_dublicates(Figure, [_|Tail], Dublicates) :-
    get_fact_dublicates(Figure, Tail, Dublicates).

    
delete_dublicates([]).
delete_dublicates([Head|Tail]) :-
    retract(figure(Head, _)),
    delete_dublicates(Tail).
delete_dublicates([_|Tail]) :-
    delete_dublicates(Tail).


delete_fact_dublicates :-
    get_all_fact_figures(Figure_facts),
    get_fact_figure_dublicates(Figure_facts, Figure_fact_dublicates),
    delete_dublicates(Figure_fact_dublicates), !.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wrapper
rotate_figure(Figure, Result_figure, Angle) :-
    find_figure_center(Figure, Center),
    find_figure_max_min(Figure, _, X_min_1, _, Y_min_1),
    rotate_figure(Figure, Rotated_figure, Center, Angle),
    find_figure_max_min(Rotated_figure, _, X_min_2, _, Y_min_2),
	move_figure(Rotated_figure, Moved_figure, -X_min_2, -Y_min_2),
    move_figure(Moved_figure, Result_figure, X_min_1, Y_min_1).
% realization
rotate_figure([], [], _, _).
rotate_figure([[X1, Y1]|T1], [[X2, Y2]|T2], [MX, MY], Angle) :-
    X2 is MX+(X1-MX)*cos(Angle)-(Y1-MY)*sin(Angle),
    Y2 is MY+(X1-MX)*sin(Angle)+(Y1-MY)*cos(Angle),
    rotate_figure(T1, T2, [MX, MY], Angle).  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

move_figure([], [], _, _).
move_figure([[X1, Y1]|T1], [[X2, Y2]|T2], DX, DY) :-
    X2 is integer(X1+DX),
    Y2 is integer(Y1+DY),
    move_figure(T1, T2, DX, DY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic field/2.

init_field(Width, Height) :-
    assertz(field(Width, Height)).

delete_field :-
    field(_, _),
    retractall(field(_, _)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

get_all_fact_field_cells(List) :-
    findall([X, Y], field_cell(X, Y), List).

:- dynamic field_cell/2.

% wrapper
add_field_cell :-
    field(Width, Height),
    add_field_cell(1, 1, Width, Height), !.
% realization
add_field_cell(X, _, Width, _) :-
    X > Width, !.
add_field_cell(X, Y, Width, Height) :- 
    Y > Height, !, 
    X_next is X+1,
    add_field_cell(X_next, 1, Width, Height).
add_field_cell(X, Y, Width, Height) :-
    assertz(field_cell(X, Y)),
    Y_next is Y+1,
    add_field_cell(X, Y_next, Width, Height).

delete_field_cells :-
    field_cell(_, _),
    retractall(field_cell(_, _)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

can_place_figure_in_field(Figure) :-
    field(Width, Height),
    find_figure_max_min(Figure, X_max, X_min, Y_max, Y_min),
    X_max =< Width, Y_max =< Height,
    X_min >= 1, Y_min >= 1. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic figure/2.

add_figure(Figure, Number) :-
    can_place_figure_in_field(Figure),
    not(figure(Figure, Number)),
    assertz(figure(Figure, Number)).

add_figure_and_its_permutations(Figure, Number) :-
    add_figure(Figure, Number),
    add_figure_and_its_permutations(Figure, Number).
add_figure_and_its_permutations(Figure, Number) :-
    rotate_figure(Figure, Rotated_figure, pi/2),
    add_figure(Rotated_figure, Number),
    add_figure_and_its_permutations(Rotated_figure, Number).
add_figure_and_its_permutations(Figure, Number) :-
    move_figure(Figure, Moved_figure, 1, 0),
    add_figure(Moved_figure, Number),
    add_figure_and_its_permutations(Moved_figure, Number).
add_figure_and_its_permutations(Figure, Number) :-
    move_figure(Figure, Moved_figure, 0, 1),
    add_figure(Moved_figure, Number),
    add_figure_and_its_permutations(Moved_figure, Number).

% wrapper
add_figures(List_of_figures) :-
    add_figures(List_of_figures, 0), !.
% realization
add_figures([], _).
add_figures([Head|_], N) :-
    Number is N+1, 
    add_figure_and_its_permutations(Head, Number).
add_figures([_|Tail], N) :-
	add_figures(Tail, N+1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

place_figure(_, []).
place_figure(List_of_field_cells, [Head|Tail]) :-
    member(Head, List_of_field_cells),
    place_figure(List_of_field_cells, Tail).

delete_field_cells(Result, [], Result).
delete_field_cells(List_of_field_cells, [Head|Tail], Result) :-
   	select(Head, List_of_field_cells, Res),
    delete_field_cells(Res, Tail, Result).

place_figures(Result) :-
    get_all_fact_field_cells(List_of_field_cells),
    place_figures(List_of_field_cells, Result, []), !;
    write("Не удалось заполнить данными фигурами область!"),
    nl, fail.

place_figures([], [], _).
place_figures(List_of_field_cells, [Head|Tail], Seq) :-
    figure(Figure, N),
    not(member(N, Seq)), 
    place_figure(List_of_field_cells, Figure),
    delete_field_cells(List_of_field_cells, Figure, Result),
    append(Seq, [N], Res),
    Head = Figure,
    place_figures(Result, Tail, Res).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% wrapper
amount_of_figure_cells(List_of_figures, Result) :-
    amount_of_figure_cells(List_of_figures, 0, Result), !.
% realization
amount_of_figure_cells([], Amount, Amount).
amount_of_figure_cells([Head|Tail], Start, Result) :-
    list_length(Head, Count),
    Amount is Start+Count,
    amount_of_figure_cells(Tail, Amount, Result).


check_field_cell_amount(Count) :-
    field(Width, Height),
    Tmp is Count+1,
    get_figures(List_of_figures, Tmp),
    Square is Width*Height,
    amount_of_figure_cells(List_of_figures, Amount),
    Amount >= Square, !;
    write("Не достаточно клеток в фигурах для заполнения введённой области!"),
    nl, fail.


check_field_parameters(Width, Height) :-
    Width >= 1,
    Height >= 1, !;
    write("Недопустимые размеры заполняемой области!"),
    nl, fail.


main(Width, Height, List_of_figures, Result) :-
    check_field_parameters(Width, Height), 
    init_field(Width, Height),
    add_field_cell,
    add_figures(List_of_figures),
    delete_fact_dublicates,
    list_length(List_of_figures, Count),
    check_field_cell_amount(Count),
    place_figures(Result),
    delete_field_cells,
    delete_field,
    !.