staload either = "lib/either.sats"
staload "lib/either.dats"
staload errno = "lib/errno.sats"
dynload "lib/either.sats"
dynload "lib/either.dats"
dynload "lib/errno.sats"
dynload "lib/errno.dats"

staload _ = "prelude/DATS/integer.dats" (* rv > 0 *)

overload = with $errno.eq_errno_errno

(*** Missing in standard library? ***)

%{
atstype_void
ats_free_boxed (
  atstype_boxed obj
) {
  ATS_MFREE(obj);
}
%}
extern fun free_boxed {a:t0p} (x : a): void = "mac#ats_free_boxed"
extern fun free_boxed_vt {a:vt0p} (x : a): void = "mac#ats_free_boxed"

(*
fun with_boxed {a:t0p} (x : a, f : (a) -<fun1> void) : void =
  let
    val () = f(x)
  in
    free_boxed(x)
  end

and below


  val () = with_boxed_vt(accept(sock),
             lam (r : $either.VT (socket_t, errno_t)) : void =<fun1>
               case+ r of
               | Left (nsock : socket_t) => assertloc(destroy(nsock, SHUT_RDWR) = EOK)
               | Right (err) => assertloc(false))

But this generates some weird error with Left_vt being an existential type
instead of a constructor?
*)


(*** socket library ***)

%{
#include <sys/socket.h>
%}

(* ATS emits the type declarations for ATS-defined types before it starts
 * processing the actual code here, so we need to make sure the declaration
 * of errno_t is placed at the beginning of the file.
 *)
%{
typedef int domain_t;
%}
abst@ype domain_t = $extype"domain_t"
macdef AF_INET = $extval(domain_t, "AF_INET")

abst@ype type_t = int
macdef SOCK_STREAM = $extval(type_t, "SOCK_STREAM")

abst@ype protocol_t = int
macdef DEFAULT_PROTOCOL = $extval(protocol_t, "0")

absviewt@ype socket_t = int
extern castfn int_of_socket(socket : socket_t):<> int
extern castfn socket_of_int(i : int):<> socket_t

extern fun create(domain : domain_t, type_ : type_t, protocol : protocol_t) : socket_t = "mac#socket"

%{
#include <arpa/inet.h>
%}
extern fun htons(i : int) : int = "mac#htons"

abst@ype sockaddr_in_t = $extype"atstype_ptr"
%{
#include <netinet/in.h>

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
%}
extern fun create_sockaddr_in(domain : domain_t, addr : int, port : int) : sockaddr_in_t = "mac#ats_create_sockaddr_in"
extern fun destroy_sockaddr_in(sockaddr : sockaddr_in_t) : void = "mac#ats_destroy_sockaddr_in"

%{
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
    return errno;
  }
}
%}
extern fun bind(socket : !socket_t, sockaddr : sockaddr_in_t) : $errno.t = "mac#ats_bind_sockaddr_in"

%{
errno_t
ats_listen (
  int sock
, int backlog
) {
  int rv = listen(sock, backlog);
  if (rv == 0) {
    return rv;
  } else {
    return errno;
  }
}
%}
extern fun listen(socket : !socket_t, backlog : int ) : $errno.t = "mac#ats_listen"

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
    return errno;
  }
}
%}
extern fun _ats_accept(socket : !socket_t) : int = "mac#ats_accept"
fun accept(socket : !socket_t) : $either.VT (socket_t, $errno.t) =
  let
    val rv = _ats_accept(socket)
  in
    if rv > 0 then
      $either.vt_left(socket_of_int(rv))
    else
      $either.vt_right($errno.errno_of_int(rv))
  end

abst@ype shutdown_t = int
macdef SHUT_RD = $extval(shutdown_t, "SHUT_RD")
macdef SHUT_WR = $extval(shutdown_t, "SHUT_WR")
macdef SHUT_RDWR = $extval(shutdown_t, "SHUT_RDWR")

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
    return errno;
  }
}
%}
extern fun destroy(socket : socket_t, how : shutdown_t) : $errno.t = "mac#ats_shutdown"

(*** echo! ***)

implement main(argc, argv) = 
  let val sock = create(AF_INET, SOCK_STREAM, DEFAULT_PROTOCOL)
      val addr_in = create_sockaddr_in(AF_INET, 0, htons(8877))
      val () = assertloc(bind(sock, addr_in) = $errno.EOK)
      val () = destroy_sockaddr_in(addr_in)
      val () = assertloc(listen(sock, 5) = $errno.EOK)
      val r = accept(sock)
      val () = case+ r of
               (* Why is the type annotation of nsock needed to compile? *)
               | $either.Left_vt (nsock : socket_t) => assertloc(destroy(nsock, SHUT_RDWR) = $errno.EOK)
               | $either.Right_vt (err) => assertloc(false)
      val () = free_boxed_vt(r)
      val () = assertloc(destroy(sock, SHUT_RDWR) = $errno.EOK)
  in 0 end
