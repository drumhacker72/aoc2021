import
  std/sequtils,
  std/strutils

func naiveStep(timers: var seq[int]) =
  for i in 0 ..< len timers:
    if timers[i] == 0:
      timers[i] = 6
      timers.add(8)
    else:
      dec(timers[i])

func fastStep(counts: var array[9, int]) =
  let spawning = counts[0]
  for i in 0..7:
    counts[i] = counts[i+1]
  inc(counts[6], spawning)
  counts[8] = spawning

let init = readLines("day6.txt", 1)[0].split(',').map(parseInt)

var timers = init
for i in 1..80:
  naiveStep(timers)
echo len timers

var counts: array[9, int]
for timer in init:
  inc(counts[timer])

for i in 1..256:
  fastStep(counts)
echo counts.foldl(a + b)
