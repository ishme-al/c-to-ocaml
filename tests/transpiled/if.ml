let () =
  let x : int = 0 in
  let y : int = 0 in
  let y, x =
    if x > y then
      let x = x + 1 in
      (y, x)
    else
      let y = y + 1 in
      (y, x)
  in
  let x =
    if x = 0 then
      let x = y in
      x
  in
  let x =
    if x = y then
      let x = x + y in
      x
  in
  exit 0
