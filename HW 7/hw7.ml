

type number = 
| Int of int
| Float of float;;


(*Actual operations*)

let apply_op op a b =
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
let tokens1 = [`Num (Int 3); `Num (Float 3.2); `Op "*"; `Num (Int 2); `Op "+"]
in assert (postfix_calculator tokens1 = Float 11.6);
 (* Example 2: 4 2 / => Int(2) *)
let tokens2 = [`Num (Int 4); `Num (Int 2); `Op "/"] in
assert (postfix_calculator tokens2 = Int 2);
 (* Example 3: 3 0 / => Division by zero (raises exception) *)
let tokens3 = [`Num (Int 3); `Num (Int 0); `Op "/"] in try let _ =
postfix_calculator tokens3 in assert false (* Should raise exception *) with
Invalid_argument "Division by zero" -> assert true

(* Test 4: Not enough operands => "Not enough operands" *)
let tokens4 = [`Op "+"; `Num (Int 3)] in
try let _ = postfix_calculator tokens4 in assert false
with Invalid_argument "Not enough operands" -> assert true

(*  Test 5: Unknown operator => "Unknown operation" *)
let tokens5 = [`Num (Int 2); `Num (Int 3); `Op "^"];;
try let _ = postfix_calculator tokens5 in assert false
with Invalid_argument "Unknown operation" -> assert true
  
(*  test 6: Int + float after  int division => Float 5.5 *)
let tokens6 = [`Num (Int 5); `Num (Int 2); `Op "/";  
               `Num (Float 3.5); `Op "+"];;         
assert (postfix_calculator tokens6 = Float 5.5);

(*  Test 7: Subtraction w negatives, then multiply => Int (-10) *)
(* 5 10 - 2 *  ==> (5 - 10) = -5;  -5 * 2 = -10 *)
let tokens7 = [`Num (Int 5); `Num (Int 10); `Op "-"; `Num (Int 2); `Op "*"] in
assert (postfix_calculator tokens7 = Int (-10));

(*  Test 8: Float division 7.5 2.5 / => Float 3.0 *)
let tokens8 = [`Num (Float 7.5); `Num (Float 2.5); `Op "/"] in
assert (postfix_calculator tokens8 = Float 3.0);

(*  Test 9: Malformed expression => "Malformed expression" *)
let tokens9 = [`Num (Int 3); `Num (Int 4); `Num (Int 5); `Op "+"] in
try let _ = postfix_calculator tokens9 in assert false
with Invalid_argument "Malformed expression" -> assert true