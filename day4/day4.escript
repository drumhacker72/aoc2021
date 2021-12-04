#!/usr/bin/env escript
-mode(compile).

read_trimmed_line(File) -> string:trim(io:get_line(File, []), trailing).

split_on_spaces(String) -> lists:filter(fun(Word) -> not string:is_empty(Word) end, string:split(String, " ", all)).

read_board(File) ->
    case io:get_line(File, []) of
        eof -> eof;
        _   -> [lists:map(fun list_to_integer/1, split_on_spaces(read_trimmed_line(File))) || _ <- lists:seq(1, 5)]
    end.

read_boards(File) ->
    case read_board(File) of
        eof -> [];
        M   -> [M | read_boards(File)]
    end.

transpose([[] | _]) -> [];
transpose(M) -> [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M)) ].

rows_and_columns(M) -> M ++ transpose(M).

remove_num_from_lines(Lines, N) -> lists:map(fun(Line) -> Line -- [N] end, Lines).

remove_num_from_boards(Boards, N) -> lists:map(fun(Lines) -> remove_num_from_lines(Lines, N) end, Boards).

is_winner(Lines) -> lists:any(fun(Line) -> length(Line) =:= 0 end, Lines).

find_winner([N | Rest], Boards) ->
    NewBoards = remove_num_from_boards(Boards, N),
    case lists:search(fun is_winner/1, NewBoards) of
        {value, Board} -> {N, Board};
        false -> find_winner(Rest, NewBoards)
    end.

find_loser([N | Rest], Boards) ->
    NewBoards = lists:filter(fun(Lines) -> not is_winner(Lines) end, remove_num_from_boards(Boards, N)),
    if
        length(NewBoards) =:= 1 -> find_winner(Rest, NewBoards);
        true -> find_loser(Rest, NewBoards)
    end.

take(0, _) -> [];
take(N, [Hd | Tl]) -> [Hd | take(N-1, Tl)].

score({LastNum, Lines}) -> LastNum * lists:sum(lists:append(take(5, Lines))).

main([]) ->
    {ok, File} = file:open("day4.txt", [read]),
    Nums = lists:map(fun list_to_integer/1, string:split(read_trimmed_line(File), ",", all)),
    Boards = lists:map(fun rows_and_columns/1, read_boards(File)),
    file:close(File),
    io:format("~b~n~b~n", [score(find_winner(Nums, Boards)), score(find_loser(Nums, Boards))]).
