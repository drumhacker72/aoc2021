defmodule Day3 do
    def transpose(rows) do
        Enum.zip_with(rows, &Function.identity/1)
    end

    def rate_bit(bits, mode) do
        avg = length(bits) / 2
        count = Enum.count(bits, fn x -> x == ?1 end)
        cmp = case mode do
            :gamma   -> &>=/2
            :epsilon -> &</2
        end
        if cmp.(count, avg) do ?1 else ?0 end
    end

    def find_rate(ratings, mode) do
        ratings |> transpose |> Enum.map(fn bits -> rate_bit(bits, mode) end)
    end

    def filter_by(ratings, mode) do
        target = ratings |> Enum.map(&hd/1) |> rate_bit(mode)
        matches = Enum.flat_map(ratings, fn [b | rest] -> if b == target, do: [rest], else: [] end)
        [target | if length(matches) == 1 do hd(matches) else filter_by(matches, mode) end]
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
