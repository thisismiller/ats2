(*** Either type ***)
(*
 * T is a boxed normal type
 * VT is a boxed viewtype
 *)

datatype either_t0ype_bool_type
  (a : t@ype+, b : t@ype+, bool) =
    Left (a, b, true) of (a)
  | Right (a, b, false) of (b)
stadef t = either_t0ype_bool_type
typedef T (a:t0p, b:t0p) = [c : bool] t (a, b, c)

fun{a:t0p}{b:t0p} t_left (a):<> t(a, b, true)
fun{a:t0p}{b:t0p} t_right (b):<> t(a, b, false)


dataviewtype either_viewt0ype_bool_type
  (a : viewt@ype+, b : viewt@ype+, bool) =
    Left_vt (a, b, true) of (a)
  | Right_vt (a, b, false) of (b)
stadef vt = either_viewt0ype_bool_type
vtypedef VT (a:vt0p, b:vt0p) = [c : bool] vt (a, b, c)


fun{a:vt0p}{b:vt0p} vt_left (a):<> vt(a, b, true)
fun{a:vt0p}{b:vt0p} vt_right (b):<> vt(a, b, false)
