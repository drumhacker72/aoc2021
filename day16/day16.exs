defmodule Day16 do
    def start_link(bits) do
        Agent.start_link fn -> bits end, name: :bits
    end

    def read(n) do
        Agent.get_and_update :bits, fn bits -> <<x::size(n), rest::bits>> = bits; {x, rest} end
    end

    def bits_remaining() do
        Agent.get :bits, fn bits -> bit_size(bits) end
    end

    def literal() do
        more = read(1)
        val = read(4)
        case more do
            0 -> <<val::4>>
            1 -> <<val::4, literal()::bits>>
        end
    end

    def packets_until_size(0) do [] end
    def packets_until_size(size) do
        {p, packet_size} = packet_with_size()
        [p | packets_until_size(size - packet_size)]
    end

    def packet_with_size() do
        pre = bits_remaining()
        p = packet()
        post = bits_remaining()
        {p, pre - post}
    end

    def packets_until_count(0) do [] end
    def packets_until_count(count) do
        p = packet()
        [p | packets_until_count(count - 1)]
    end

    def operation(type_id) do
        case type_id do
            0 -> &Enum.sum/1
            1 -> &Enum.product/1
            2 -> &Enum.min/1
            3 -> &Enum.max/1
            _ -> fn ps ->
                [a, b] = ps
                case type_id do
                    5 -> if a > b, do: 1, else: 0
                    6 -> if a < b, do: 1, else: 0
                    7 -> if a === b, do: 1, else: 0
                end
            end
        end
    end

    def packet() do
        version = read(3)
        type_id = read(3)
        case type_id do
            4 ->
                lit_bits = literal()
                s = bit_size(lit_bits)
                <<lit::size(s)>> = lit_bits
                {version, lit}
            _ ->
                op = operation(type_id)
                length_type_id = read(1)
                ps = case length_type_id do
                    0 ->
                        size = read(15)
                        packets_until_size(size)
                    1 ->
                        count = read(11)
                        packets_until_count(count)
                end
                {version, op, ps}
        end
    end

    def version_sum({version, _value}) do version end
    def version_sum({version, _op, packets}) do
        version + (packets |> Enum.map(&version_sum/1) |> Enum.sum())
    end

    def reduce({_version, value}) when is_integer value do value end
    def reduce({_version, op, packets}) do
        packets |> Enum.map(&reduce/1) |> op.()
    end
end

{:ok, file} = File.open("day16.txt", [:read])
{:ok, bits} = IO.read(file, :line) |> String.trim_trailing |> Base.decode16()
File.close(file)
Day16.start_link(bits)
p = Day16.packet()
IO.puts Day16.version_sum(p)
IO.puts Day16.reduce(p)
