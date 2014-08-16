staload "lib/socket.sats"
staload "lib/either.sats"
staload "lib/either.dats"
staload _ = "prelude/DATS/integer.dats" (* rv > 0 *)

%{
atstype_ptr
ats_create_sockaddr_in (
  domain_t af
, in_addr_t inp
, in_port_t port
) {
  struct sockaddr_in *sa = malloc(sizeof(*sa)) ;
  (void)memset(sa, 0, sizeof (struct sockaddr_in)) ;
  sa->sin_family = af ;
  sa->sin_addr.s_addr = inp ;
  sa->sin_port = port ;
  return sa;
} // end of [sockaddr_in_init]

atstype_void
ats_destroy_sockaddr_in (
  atstype_ptr sa
) {
  free(sa);
}

errno_t
ats_bind_sockaddr_in (
  int sock
, atstype_ptr sockaddr
) {
  int optval = 1;
  setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(int));
  int rv = bind(sock, sockaddr, sizeof(struct sockaddr_in));
  if (rv == 0) {
    return rv;
  } else {
    return -errno;
  }
}

errno_t
ats_listen (
  int sock
, int backlog
) {
  int rv = listen(sock, backlog);
  if (rv == 0) {
    return rv;
  } else {
    return -errno;
  }
}
%}


%{
atstype_int
ats_accept (
  int socket
) {
  // TODO: figure out multiple return values and return address also
  int rv = accept(socket, NULL, NULL);
  if (rv > 0) {
    return rv;
  } else {
    return -errno;
  }
}
%}
extern fun _ats_accept(socket : !socket_t) : int = "mac#ats_accept"
implement accept(socket) =
  let
    val rv = _ats_accept(socket)
  in
    if rv > 0 then
      $either.vt_left(socket_of_int(rv))
    else
      $either.vt_right($errno.errno_of_int(rv))
  end

implement destroy_accept_either(vt) =
  case+ vt of
  | ~Left_vt(a) => ignoret(destroy(a, SHUT_RDWR))
  | ~Right_vt(b) => ()

%{
errno_t
ats_recv (
  int sock
, void* buf
, size_t len
) {
  int rv = recv(sock, buf, len, 0);
  if (rv >= 0) {
    return rv;
  } else {
    return -errno;
  }
}
%}
extern fun _ats_recv {a : vt@ype+}{p : addr}{l : nat}{n : nat | n <= l}
    (pf : !array_v (a?, p, l) | socket : !socket_t, buf : ptr p, len : size_t n)
    : [r : int | r <= n] int r = "mac#ats_recv"

implement recv (pf | socket, buf, len) =
  case+ _ats_recv(pf | socket, buf, len) of
  | rv when rv >= 0 => $either.t_left(i2sz(rv))
  | rv => #[0 | $either.t_right($errno.errno_of_int(0-rv))]


%{
errno_t
ats_send (
  int sock
, void* buf
, size_t len
) {
  int rv = send(sock, buf, len, 0);
  if (rv >= 0) {
    return rv;
  } else {
    return -errno;
  }
}
%}
extern fun _ats_send {a : vt@ype+}{p : addr}{l : int}{n : int | n <= l}
    (pf : !array_v (a, p, l) | socket : !socket_t, buf : ptr p, len : size_t n)
    : [r : int | r <= n] int r = "ats_send"

implement send (pf | socket, buf, len) =
  case+ _ats_send(pf | socket, buf, len) of
  | rv when rv >= 0 => $either.t_left(i2sz(rv))
  | rv => #[0 | $either.t_right($errno.errno_of_int(rv))]

%{
errno_t
ats_shutdown (
  int socket
, int how
) {
  int rv = shutdown(socket, how);
  if (rv == 0) {
    return rv;
  } else {
    return -errno;
  }
}
%}
