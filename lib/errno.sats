(* ATS emits the type declarations for ATS-defined types before it starts
 * processing the actual code here, so we need to make sure the declaration
 * of errno_t is placed at the beginning of the file.
 *)
%{^
#include <errno.h>
typedef int errno_t;
%}
abst@ype t = $extype"errno_t"
castfn int_of_errno(err : t):<> int
castfn errno_of_int(i : int):<> t

macdef EOK = errno_of_int(0)

%{
atstype_bool op_errno_eq_errno(errno_t lhs, errno_t rhs);
%}

symintr =
fun eq_errno_errno(t, t): bool = "mac#op_errno_eq_errno"
overload = with eq_errno_errno of 0

