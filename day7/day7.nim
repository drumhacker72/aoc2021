import
  std/sequtils,
  std/strutils

type Mode = enum part1, part2

func sumToN(n: int): int = n*(n+1) div 2

func cost(pos: seq[int], i: int, mode: Mode): int =
  pos.foldl(a + (let delta = abs(b - i); case mode
    of part1: delta
    of part2: sumToN(delta)
  ), 0)

if isMainModule:
  let pos = readLines("day7.txt", 1)[0].split(',').map(parseInt)
  for mode in [part1, part2]:
    let costs = mapIt(0 ..< len pos, cost(pos, it, mode))
    echo min costs
