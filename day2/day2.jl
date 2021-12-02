mutable struct State1
    pos::Int
    depth::Int
end

cmds1 = Dict(
    :forward => (s, x) -> s.pos += x,
    :down    => (s, x) -> s.depth += x,
    :up      => (s, x) -> s.depth -= x
)

mutable struct State2
    pos::Int
    depth::Int
    aim::Int
end

cmds2 = Dict(
    :down    => (s, x) -> s.aim += x,
    :up      => (s, x) -> s.aim -= x,
    :forward => (s, x) -> (s.pos += x; s.depth += s.aim*x)
)

simulate!(state, cmds, lines) = foreach(((k, x),) -> cmds[k](state, x), lines)

lines = map(eachline("day2.txt")) do line
    k, x = split(line, " ")
    Symbol(k), parse(Int, x)
end

part1 = State1(0, 0)
simulate!(part1, cmds1, lines)
println(part1.pos * part1.depth)

part2 = State2(0, 0, 0)
simulate!(part2, cmds2, lines)
println(part2.pos * part2.depth)
