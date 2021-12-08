import
  std/sequtils,
  std/strutils,
  std/sugar

type
  Segment = enum a, b, c, d, e, f, g
  SegmentSet = set[Segment]

func parseDigit(segChars: string): SegmentSet =
  for segChar in segChars:
    let segment = case segChar
      of 'a': a
      of 'b': b
      of 'c': c
      of 'd': d
      of 'e': e
      of 'f': f
      else: g
    incl(result, segment)

func search[T](xs: openArray[T], pred: proc(x: T): bool): T =
  for x in xs:
    if pred x:
      result = x
      break

proc extract[E](xs: set[E]): E =
  assert card(xs) == 1
  for x in xs:
    result = x
    break

proc toArray[N: static int; T](xs: seq[T]): array[N, T] =
  for i in 0 ..< len xs:
    result[i] = xs[i]

proc analyze(patterns: array[10, SegmentSet]): array[10, SegmentSet] =
  let one = patterns.search(pattern => card(pattern) == 2)
  let four = patterns.search(pattern => card(pattern) == 4)
  let seven = patterns.search(pattern => card(pattern) == 3)
  let eight = patterns.search(pattern => card(pattern) == 7)

  let six = patterns.search(pattern => card(pattern) == 6 and not (one < pattern))
  let trueC = extract(four - six)
  let trueF = extract(one - {trueC})
  let three = patterns.search(pattern => card(pattern) == 5 and trueC in pattern and trueF in pattern)
  let two = patterns.search(pattern => card(pattern) == 5 and trueC in pattern and trueF notin pattern)
  let five = patterns.search(pattern => card(pattern) == 5 and trueC notin pattern and trueF in pattern)
  let trueB = extract(five - three)
  let trueD = extract(four - {trueB, trueC, trueF})
  let trueE = extract(two - three)
  let zero = patterns.search(pattern => card(pattern) == 6 and trueD notin pattern)
  let nine = patterns.search(pattern => card(pattern) == 6 and trueE notin pattern)
  result = [zero, one, two, three, four, five, six, seven, eight, nine]

if isMainModule:
  var easyDigits = 0
  let numbers = collect:
    for line in io.lines("day8.txt"):
      let entry = line.split(" | ")
      let signalPatterns = entry[0].split(" ").map(parseDigit)
      let outputValue = entry[1].split(" ").map(parseDigit)
      let mapping = analyze(toArray[10, SegmentSet](signalPatterns))
      let digits = collect:
        for segments in outputValue:
          let digit = mapping.find(segments)
          if digit in [1, 4, 7, 8]:
            inc(easyDigits)
          digit
      digits[0]*1000 + digits[1]*100 + digits[2]*10 + digits[3]
  echo easyDigits
  echo numbers.foldl(a+b, 0)
