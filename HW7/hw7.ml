

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


let approx_equal a b =
  match (a, b) with
  | Float x, Float y -> abs_float (x -. y) < 0.0001
  | Int x, Int y -> x = y
  | Int x, Float y -> abs_float (float_of_int x -. y) < 0.0001
  | Float x, Int y -> abs_float (x -. float_of_int y) < 0.0001;;
