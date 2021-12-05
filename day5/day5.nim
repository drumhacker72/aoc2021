from std/sequtils import filter, map, toSeq
from std/strscans import scanf
import std/tables

type
  Point = tuple[x, y: int]
  Line = tuple[x1, y1, x2, y2: int]

func delta(a, b: int): int =
  if a < b: 1
  elif a == b: 0
  else: -1

iterator points(line: Line, diagonals: bool): Point =
  var x = line.x1
  var y = line.y1
  let dx = delta(line.x1, line.x2)
  let dy = delta(line.y1, line.y2)
  if diagonals or dx == 0 or dy == 0:
    while x != line.x2+dx or y != line.y2+dy:
      yield (x, y)
      inc(x, dx)
      inc(y, dy)

let lines = io.lines("day5.txt").toSeq.map(func (line: string): Line =
  var x1, y1, x2, y2: int
  assert scanf(line, "$i,$i -> $i,$i$.", x1, y1, x2, y2)
  (x1, y1, x2, y2))

var counts1 = initCountTable[Point]()
var counts2 = initCountTable[Point]()
for line in lines:
  for p in line.points(diagonals = false):
    counts1.inc(p)
  for p in line.points(diagonals = true):
    counts2.inc(p)

func countDangerous(counts: CountTable[Point]): int =
  counts.values.toSeq.filter(func (x: int): bool = x >= 2).len

echo countDangerous(counts1)
echo countDangerous(counts2)
