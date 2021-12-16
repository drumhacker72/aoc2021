defmodule Day16 do
    def literal(bits) do
        <<more::1, val::4, rest::bits>> = bits
        if more === 0 do
            {<<val::4>>, rest}
        else
            {restLit, restExtra} = literal(rest)
            {<<val::4, restLit::bits>>, restExtra}
        end
    end

    def packetsUntilSize(bits, size) do
        if size === 0 do
            {[], bits}
        else
            {p, rest} = packet(bits)
            {ps, rest2} = packetsUntilSize(rest, size - (bit_size(bits) - bit_size(rest)))
            {[p | ps], rest2}
        end
    end

    def packetsUntilCount(bits, count) do
        if count === 0 do
            {[], bits}
        else
            {p, rest} = packet(bits)
            {ps, rest2} = packetsUntilCount(rest, count - 1)
            {[p | ps], rest2}
        end
    end

    def packet(bits) do
        <<_version::3, typeId::3, rest::bits>> = bits
        case typeId do
            4 ->
                {lit, rest2} = Day16.literal(rest)
                s = bit_size(lit)
                <<lit2::size(s)>> = lit
                {lit2, rest2}
            _ ->
                <<lengthTypeId::1, rest2::bits>> = rest
                {ps, rest4} = case lengthTypeId do
                    0 ->
                        <<totalSize::15, rest3::bits>> = rest2
                        packetsUntilSize(rest3, totalSize)
                    1 ->
                        <<numSubpackets::11, rest3::bits>> = rest2
                        packetsUntilCount(rest3, numSubpackets)
                end
                v = case typeId do
                    0 -> Enum.sum(ps)
                    1 -> Enum.product(ps)
                    2 -> Enum.min(ps)
                    3 -> Enum.max(ps)
                    _ ->
                        [a, b] = ps
                        case typeId do
                            5 -> if a > b, do: 1, else: 0
                            6 -> if a < b, do: 1, else: 0
                            7 -> if a === b, do: 1, else: 0
                        end
                end
                {v, rest4}
        end
    end
end

{:ok, a} = Base.decode16("A052E04CFD9DC0249694F0A11EA2044E200E9266766AB004A525F86FFCDF4B25DFC401A20043A11C61838600FC678D51B8C0198910EA1200010B3EEA40246C974EF003331006619C26844200D414859049402D9CDA64BDEF3C4E623331FBCCA3E4DFBBFC79E4004DE96FC3B1EC6DE4298D5A1C8F98E45266745B382040191D0034539682F4E5A0B527FEB018029277C88E0039937D8ACCC6256092004165D36586CC013A008625A2D7394A5B1DE16C0E3004A8035200043220C5B838200EC4B8E315A6CEE6F3C3B9FFB8100994200CC59837108401989D056280803F1EA3C41130047003530004323DC3C860200EC4182F1CA7E452C01744A0A4FF6BBAE6A533BFCD1967A26E20124BE1920A4A6A613315511007A4A32BE9AE6B5CAD19E56BA1430053803341007E24C168A6200D46384318A6AAC8401907003EF2F7D70265EFAE04CCAB3801727C9EC94802AF92F493A8012D9EABB48BA3805D1B65756559231917B93A4B4B46009C91F600481254AF67A845BA56610400414E3090055525E849BE8010397439746400BC255EE5362136F72B4A4A7B721004A510A7370CCB37C2BA0010D3038600BE802937A429BD20C90CCC564EC40144E80213E2B3E2F3D9D6DB0803F2B005A731DC6C524A16B5F1C1D98EE006339009AB401AB0803108A12C2A00043A134228AB2DBDA00801EC061B080180057A88016404DA201206A00638014E0049801EC0309800AC20025B20080C600710058A60070003080006A4F566244012C4B204A83CB234C2244120080E6562446669025CD4802DA9A45F004658527FFEC720906008C996700397319DD7710596674004BE6A161283B09C802B0D00463AC9563C2B969F0E080182972E982F9718200D2E637DB16600341292D6D8A7F496800FD490BCDC68B33976A872E008C5F9DFD566490A14")
{p, _} = Day16.packet(a)
IO.puts p
