staload "lib/errno.sats"

%{
atstype_bool
op_errno_eq_errno(
  errno_t lhs
, errno_t rhs
) {
  return lhs == rhs;
}
%}
