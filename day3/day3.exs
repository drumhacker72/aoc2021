defmodule Day3 do
    def transpose(rows) do
        Enum.zip_with(rows, &Function.identity/1)
    end

    def find_rate(ratings, mode) do
        avg = length(ratings) / 2
        counts = ratings |> transpose |> Enum.map(fn digits -> Enum.count(digits, fn x -> x == ?1 end) end)
        cmp = case mode do
            :gamma   -> &>=/2
            :epsilon -> &</2
        end
        Enum.map(counts, fn count -> if cmp.(count, avg), do: ?1, else: ?0 end)
    end

    def filter_by(ratings, mode) do
        c = ratings |> find_rate(mode) |> hd
        matches = Enum.flat_map(ratings, fn [d | ds ] -> if d == c, do: [ds], else: [] end)
        [c | if length(matches) == 1 do hd(matches) else filter_by(matches, mode) end]
    end
end

ratings = File.stream!("day3.txt") |> Enum.map(fn line ->
    line |> String.trim_trailing() |> String.to_charlist()
end)

gamma = to_string(Day3.find_rate(ratings, :gamma))
epsilon = to_string(Day3.find_rate(ratings, :epsilon))
IO.puts(String.to_integer(gamma, 2) * String.to_integer(epsilon, 2))

oxygen_gen = to_string(Day3.filter_by(ratings, :gamma))
co2_scrub = to_string(Day3.filter_by(ratings, :epsilon))
IO.puts(String.to_integer(oxygen_gen, 2) * String.to_integer(co2_scrub, 2))
