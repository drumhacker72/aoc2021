open Angstrom

type element =
  | Regular of int
  | Pair of pair
and pair = element * element

let brackets p = char '[' *> p <* char ']'
let digit = satisfy (function '0' .. '9' -> true | _ -> false) >>| fun c -> Char.code c - Char.code '0'
let pair e : pair t = brackets (both e (char ',' *> e))
let element : element t =
  fix (fun element ->
    let regular = digit >>| fun d -> Regular d in
    let pair = pair element >>| fun (a, b) -> Pair (a, b) in
    regular <|> pair)

let read_lines filename : string list =
  let ic = open_in filename in
  let rec build_lines acc =
    match input_line ic with
    | line -> build_lines (line :: acc)
    | exception End_of_file -> close_in ic; List.rev acc in
  build_lines []

let parse (str:string) : pair =
  match parse_string ~consume:All (pair element) str with
  | Ok v -> v
  | Error msg -> failwith msg

let rec string_of_element (e:element) : string =
  match e with
  | Regular n -> string_of_int n
  | Pair (a, b) -> string_of_pair (a, b)
and string_of_pair (a, b) : string =
  "[" ^ string_of_element a ^ "," ^ string_of_element b ^ "]"

type explode_result =
  | ExplodeLeft of int * pair
  | ExplodeRight of pair * int
  | Exploded of pair
  | NoExplode

let rec explode_left e x =
  match e with
  | Regular n -> Regular (n + x)
  | Pair (a, b) -> Pair (a, explode_left b x)
let rec explode_right x e =
  match e with
  | Regular n -> Regular (x + n)
  | Pair (a, b) -> Pair (explode_right x a, b)

let rec explode depth (a, b) =
  match (depth, a, b) with
  | (4, Pair (Regular aa, Regular ab), b) -> ExplodeLeft (aa, (Regular 0, explode_right ab b))
  | (4, Regular a, Pair (Regular ba, Regular bb)) -> ExplodeRight ((Regular (a + ba), Regular 0), bb)
  | (4, Regular _, Regular _) -> NoExplode
  | _ ->
    let left = match a with
    | Pair (aa, ab) -> (match explode (depth+1) (aa, ab) with
      | ExplodeLeft (x, p) -> ExplodeLeft (x, (Pair p, b))
      | ExplodeRight (p, x) -> Exploded (Pair p, explode_right x b)
      | Exploded p -> Exploded (Pair p, b)
      | NoExplode -> NoExplode)
    | Regular _ -> NoExplode in
    if left = NoExplode then
      match b with
      | Pair (ba, bb) -> (match explode (depth+1) (ba, bb) with
        | ExplodeLeft (x, p) -> Exploded (explode_left a x, Pair p)
        | ExplodeRight (p, x) -> ExplodeRight ((a, Pair p), x)
        | Exploded p -> Exploded (a, Pair p)
        | NoExplode -> NoExplode)
      | Regular _ -> NoExplode
    else left

type split_result =
  | Split of pair
  | NoSplit

let rec split_e e =
  match e with
  | Regular n -> if n >= 10 then Split (Regular (n / 2), Regular ((n + 1) / 2)) else NoSplit
  | Pair (a, b) -> split (a, b)
and split (a, b) =
  match split_e a with
  | Split p -> Split (Pair p, b)
  | NoSplit -> (match split_e b with
    | Split p -> Split (a, Pair p)
    | NoSplit -> NoSplit)

let rec reduce (a, b) =
  match explode 1 (a, b) with
  | ExplodeLeft (_, p) -> reduce p
  | ExplodeRight (p, _) -> reduce p
  | Exploded p -> reduce p
  | NoExplode -> (match split (a, b) with
    | Split p -> reduce p
    | NoSplit -> (a, b))

let add a b = reduce (Pair a, Pair b)

let rec magnitude e =
  match e with
  | Pair (a, b) -> 3 * magnitude a + 2 * magnitude b
  | Regular n -> n

let lines = read_lines "day18.txt"
let pairs = List.map parse lines
let () = match pairs with
  | [] -> failwith "no input"
  | first::ps ->
    let acc = ref first in
    let () = List.iter (fun p -> acc := add !acc p) ps in
    print_endline (string_of_int (magnitude (Pair !acc)))

let largest = ref 0
let check a b =
  if not (a = b) then
    let m = magnitude (Pair (add a b)) in
    if m > !largest then largest := m

let () = List.iter (fun a -> List.iter (fun b -> check a b) pairs) pairs
let () = print_endline (string_of_int !largest)
