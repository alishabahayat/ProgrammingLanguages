:- use_module(library(clpfd)).

/* *********** HW13 ***********

Student names: Alishaba Hayat, Theodore Harsha
Resources: 

The overall goal of this assignment is to see how you well you can approach a new Prolog program. Start with a small and easy problem to solve and work your way up. Leave the early successful programs as comments so I can see your approach. Even if you can�t get very far, solving smaller easier problems along the way shows some skill with Prolog.

Create a Prolog program that will solve the 64 Rooks problem (starting with smaller versions) described below. Run your program against your own
specific queries. Include both the queries and the results of those
queries as comments in your file.

The "64 Rooks Problem": 
1.) You are given a chessboard (8 x 8 grid).
2.) You are given 64 rooks, each with a given color (you can think of
	these as red, blue, orange, etc.) and made of a certain material
	(you can think of these as wood, glass, steel, etc.).
3.) There are 8 unique colors and 8 unique materials, producing 64 unique
	combinations. Each of the 64 rooks is a unique combination of color
	and material. 
	- There are 8 groups of 8 rooks, each group is a different color
	- Within each group of 8, each rook is made of a unique material
4.) Place the 64 rooks on the chessboard such that no rook is able to
	attack (or check) a rook of the same color or of the same material.
5.) Rooks can only move horizontally or vertically. They can attack any
	other rook in the same row or column. They can not attack diagonally.

The 64 rooks could be described the following way:
		C1M1 C1M2 C1M3 ... C1M8
		C2M1 C2M2 C2M3 ... C2M8
		...
		C8M1 C8M2 C8M3 ... C8M8
		(note: not a legal solution, just a way to show rook labeling)

Here C stands for color and M stands for material. C1M3 signifies a
rook that is Color 1 and has Material 3. The colors are 1-8 and the
materials are 1-8. You may use a different representation than this as
long as you can clearly explain it.

Given this labeling scheme, C2M3 can not be in a row or column that
contains any C2 (C2M1, C2M2, etc.) or M3 (C1M3, C3M3, etc.) rooks.

As Prolog programs can be slow, begin by creating a program that can
solve this problem for a board of size 3 (3 x 3 grid with 9 rooks).
An example solution that it might find -
		C1M1 C2M3 C3M2
		C2M2 C3M1 C1M3
		C3M3 C1M2 C2M1

After solving for size 3, attempt to increase the size to 4, 5, 6, 7, and 8.

For each of these sizes, place in your comments the exact query needed
and the output from running that query. You may use different variable
names and/or labels than the ones shown above as long as you clearly
explain in your comments.
If a query doesn�t complete after a few minutes, try something else.
If some of these sizes can not be completed, explain why. 

Submit your working Prolog program as a single .ml file named HW13.pl
If you get stuck, refer to the examples that we have covered:
- wolf, goat, cabbage
- 8-Queens
- N-Queens
- Soduku

If you have trouble solving for larger sizes, you may want to solve for just one property first, then attempt to solve for the second property.

Feel free to use the clpfd library, which we mentioned in class.
An example of the N-Queens problem that using the clpfd library can
be found at: https://swish.swi-prolog.org/example/clpfd_queens.pl
Swish also has other examples that may be useful.

*********** */







%all c/m pairs 
build_rooks(N, Rooks) :-
    findall(C/M, (between(1,N,C), between(1,N,M)), Rooks).

no_repeat([]). %like all_distinct from the slides
no_repeat([H|T]) :-
    \+ member(H, T),
    no_repeat(T).

check_row_format([], [], []).
check_row_format([C/M | Rest], [C | Cs], [M | Ms]) :-
    check_row_format(Rest, Cs, Ms).

valid_row(Row) :-
    check_row_format(Row, Cs, Ms),
    all_distinct(Cs),
    all_distinct(Ms).

%changed to 4 
solve_row(N, Row, RooksIn, RooksOut) :-
    length(Row, N),
    select_rooks(Row, RooksIn),
    valid_row(Row),
    subtract(RooksIn, Row, RooksOut).


select_rooks([], _).
select_rooks([R|Rs], Rooks) :-
    select(R, Rooks, Rest),
    select_rooks(Rs, Rest).

% get c/m at the index for ALL rows
column_values(_, [], []).
column_values(Index, [Row|Rows],[Val|Vals]) :-
    nth1(Index, Row, C/M),
    Val = C/M, 
    column_values(Index, Rows, Vals).

%check repeats of c or m
valid_cols(Board) :-
    transpose(Board, Columns),
    forall(member(Col, Columns),
           ( check_row_format(Col, Cs, Ms),
             no_repeat(Cs),
             no_repeat(Ms) )).

%build theb solve
solve_board(N, Board) :-
    build_rooks(N, AllRooks),
    finish_rows(N, N, AllRooks, [], Board).
    

%row by row checks validity and adds to ovr board
finish_rows(0, _, _, Board, Board) :- !.
finish_rows(RowsLeft, N, RooksAvail, Partial, Board) :-
    solve_row(N, Row, RooksAvail, RooksLeft),
    append(Partial, [Row], NewPartial),
    valid_cols(NewPartial),
    R1 is RowsLeft - 1,
    finish_rows(R1, N, RooksLeft, NewPartial, Board).


/*?- solve_board(3, B), maplist(writeln, B).
[1/1,2/2,3/3]
[2/3,3/1,1/2]
[3/2,1/3,2/1]
B = [[1/1, 2/2, 3/3], [2/3, 3/1, 1/2], [3/2, 1/3, 2/1]] .

?- solve_board(4, B), maplist(writeln, B).
[1/1,2/2,3/3,4/4]
[2/3,1/4,4/1,3/2]
[3/4,4/3,1/2,2/1]
[4/2,3/1,2/4,1/3]
B = [[1/1, 2/2, 3/3, 4/4], [2/3, 1/4, 4/1, 3/2], [3/4, 4/3, 1/2, 2/1], [4/2, 3/1, 2/4, 1/3]] 

?- solve_board(5,B), maplist(writeln, B).
[1/1,2/2,3/3,4/4,5/5]
[2/3,3/4,4/5,5/1,1/2]
[3/5,4/1,5/2,1/3,2/4]
[4/2,5/3,1/4,2/5,3/1]
[5/4,1/5,2/1,3/2,4/3]
B = [[1/1, 2/2, 3/3, 4/4, 5/5], [2/3, 3/4, 4/5, 5/1, 1/2], [3/5, 4/1, 5/2, 1/3, 2/4], [4/2, 5/3, 1/4, 2/5, 3/1], [5/4, 1/5, 2/1, 3/2, 4/3]].

?- solve_board(6,B), maplist(writeln, B).
This method can be solved however it takes a long time to run due to the number of combinations.
?- solve_board(7,B), maplist(writeln, B).
This method can be solved however it takes a long time to run due to the number of combinations.
?- solve_board(8,B), maplist(writeln, B).
This method can be solved however it takes a long time to run due to the number of combinations.
*/