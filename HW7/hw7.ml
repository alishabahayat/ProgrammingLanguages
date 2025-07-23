

type number = 
| Int of int
| Float of float;;


(*Actual operations*)

let rec apply_op op a b =
  match (a, b, op) with
  | (Int x, Int y, "-") -> Int (x - y)
  | (Int x, Int y, "+") -> Int (x + y)
  | (Int x, Int y, "*") -> Int (x * y)
  | (Int x, Int y, "/") ->
      if y = 0 then raise (Invalid_argument "Division by zero")
      else Int (x / y)
  | (Float x, Float y, "-") -> Float (x -. y)
  | (Float x, Float y, "+") -> Float (x +. y)
  | (Float x, Float y, "*") -> Float (x *. y)
  | (Float x, Float y, "/") ->
      if y = 0.0 then raise (Invalid_argument "Division by zero")
      else Float (x /. y)
  | (Int x, Float y, op) -> apply_op op (Float (float_of_int x)) (Float y)
  | (Float x, Int y, op) -> apply_op op (Float x) (Float (float_of_int y))
  | _ -> raise (Invalid_argument "Unknown operation")




let postfix_calculator tokens =
  let process op_stack token =
    match token with
    | `Num value -> value :: op_stack
    | `Op op ->
        match op_stack with
        | b :: a :: rest -> (apply_op op a b) :: rest
        | _ -> raise (Invalid_argument "Not enough operands")
  in
  match List.fold_left process [] tokens with
  | [result] -> result
  | _ -> raise (Invalid_argument "Malformed expression")




(* Given asserts*)

(* Example 1: 3 3.2 * 2 + => Float(11.6) *)
let tokens1 = [`Num (Int 3); `Num (Float 3.2); `Op "*"; `Num (Int 2); `Op "+"] ;;
assert (postfix_calculator tokens1 = Float 11.6);;

(* Example 2: 4 2 / => Int(2) *)
let tokens2 = [`Num (Int 4); `Num (Int 2); `Op "/"] ;;
assert (postfix_calculator tokens2 = Int 2);;

(* Example 3: 3 0 / => Division by zero (raises exception) *)
let tokens3 = [`Num (Int 3); `Num (Int 0); `Op "/"] ;;
try
  let _ = postfix_calculator tokens3 in
  assert false (* Should raise exception *)
with Invalid_argument "Division by zero" -> assert true ;;
