defmodule Day16.State do
    @type state(s, a) :: (s -> {a, s})

    @spec chain(state(s, a), (a -> state(s, b))) :: state(s, b) when s: var, a: var, b: var
    def chain(x, f) do
        fn s1 -> {a, s2} = run(x, s1); run(f.(a), s2) end
    end

    @spec return(a) :: state(any(), a) when a: var
    def return(x) do
        fn s -> {x, s} end
    end

    @spec get() :: state(s, s) when s: var
    def get() do
        fn s -> {s, s} end
    end

    @spec run(state(s, a), s) :: {a, s} when s: var, a: var
    def run(x, s) do
        x.(s)
    end
end

defmodule Day16 do
    import Day16.State

    @type state(a) :: Day16.State.state(bitstring(), a)
    @type version() :: <<_::3>>
    @type packet() :: {version(), integer() | {(list(packet) -> integer()), list(packet())}}

    @spec read(integer()) :: state(bitstring())
    def read(n) do
        fn bits -> <<x::size(n), rest::bits>> = bits; {x, rest} end
    end

    @spec bits_remaining() :: state(integer())
    def bits_remaining() do
        get() |> chain(fn bits -> return bit_size(bits) end)
    end

    @spec literal() :: state(bitstring())
    def literal() do
        read(1) |> chain(fn more ->
            read(4) |> chain(fn val ->
                case more do
                    0 -> return <<val::4>>
                    1 -> literal() |> chain(fn low_bits -> return <<val::4, low_bits::bits>> end)
                end
            end)
        end)
    end

    @spec packets_until_size(integer()) :: state(list(packet()))
    def packets_until_size(size) do
        if size === 0 do
            return []
        else
            packet_with_size() |> chain(fn {p, packet_size} ->
                packets_until_size(size - packet_size) |> chain(fn ps -> return [p | ps] end)
            end)
        end
    end

    @spec packet_with_size() :: state({packet(), integer()})
    def packet_with_size() do
        bits_remaining() |> chain(fn pre ->
            packet() |> chain(fn p ->
                bits_remaining() |> chain(fn post -> return {p, pre - post} end)
            end)
        end)
    end

    @spec packets_until_count(integer()) :: state(list(packet()))
    def packets_until_count(count) do
        if count === 0 do
            return []
        else
            packet() |> chain(fn p ->
                packets_until_count(count - 1) |> chain(fn ps -> return [p | ps] end)
            end)
        end
    end

    @spec operation(integer()) :: (list(integer()) -> integer())
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

    @spec packet() :: state(packet())
    def packet() do
        read(3) |> chain(fn version ->
            read(3) |> chain(fn type_id ->
                case type_id do
                    4 ->
                        literal() |> chain(fn lit_bits ->
                            s = bit_size(lit_bits)
                            <<lit::size(s)>> = lit_bits
                            return {version, lit}
                        end)
                    _ ->
                        op = operation(type_id)
                        read(1) |> chain(fn length_type_id ->
                            case length_type_id do
                                0 -> read(15) |> chain(fn size ->
                                    packets_until_size(size) |> chain(fn ps -> return {version, {op, ps}} end)
                                end)
                                1 -> read(11) |> chain(fn count ->
                                    packets_until_count(count) |> chain(fn ps -> return {version, {op, ps}} end)
                                end)
                            end
                        end)
                end
            end)
        end)
    end

    def version_sum({version, contents}) do
        if is_integer(contents) do
            version
        else
            {_op, packets} = contents
            version + Enum.sum(Enum.map(packets, &version_sum/1))
        end
    end

    def reduce({_version, contents}) do
        if is_integer(contents) do
            contents
        else
            {op, packets} = contents
            op.(Enum.map(packets, &reduce/1))
        end
    end
end

{:ok, file} = File.open("day16.txt", [:read])
{:ok, bits} = IO.read(file, :line) |> String.trim_trailing |> Base.decode16()
File.close(file)
{p, _} = Day16.State.run(Day16.packet(), bits)
IO.puts Day16.version_sum(p)
IO.puts Day16.reduce(p)
