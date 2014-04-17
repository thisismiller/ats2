
%{
#include <sys/socket.h>
%}

(*** socket library ***)

%{
#include <errno.h>
typedef int error_t;
%}
abst@ype error_t = $extype"error_t"
extern castfn int_of_error(err : error_t):<> int
extern castfn error_of_int(i : int):<> error_t

macdef EOK = error_of_int(0)

%{
atstype_bool
op_error_eq_error(
  error_t lhs
, error_t rhs
) {
  return lhs == rhs;
}
%}
symintr =
extern fun eq_error_error(lhs : error_t, rhs : error_t): bool = "mac#op_error_eq_error"
overload = with eq_error_error of 0

%{
typedef int domain_t;
%}
abst@ype domain_t = $extype"domain_t"
macdef AF_INET = $extval(domain_t, "AF_INET")

abst@ype type_t = int
macdef SOCK_STREAM = $extval(type_t, "SOCK_STREAM")

abst@ype protocol_t = int
macdef DEFAULT_PROTOCOL = $extval(protocol_t, "0")

abst@ype socket_t = int
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
error_t
ats_bind_sockaddr_in (
  int sock
, atstype_ptr sockaddr
) {
  int rv = bind(sock, sockaddr, sizeof(struct sockaddr_in));
  if (rv == 0) {
    return rv;
  } else {
    return errno;
  }
}
%}
extern fun bind(socket : socket_t, sockaddr : sockaddr_in_t) : error_t = "mac#ats_bind_sockaddr_in"

%{
error_t
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
extern fun listen(socket : socket_t, backlog : int ) : error_t = "mac#ats_listen"

abst@ype shutdown_t = int
macdef SHUT_RD = $extval(shutdown_t, "SHUT_RD")
macdef SHUT_WR = $extval(shutdown_t, "SHUT_WR")
macdef SHUT_RDWR = $extval(shutdown_t, "SHUT_RDWR")

%{
error_t
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
extern fun destroy(socket : socket_t, how : shutdown_t) : error_t = "mac#ats_shutdown"

(*** echo! ***)

implement main(argc, argv) = 
  let val sock = create(AF_INET, SOCK_STREAM, DEFAULT_PROTOCOL)
      val addr_in = create_sockaddr_in(AF_INET, 0, htons(8877))
      val () = assertloc(bind(sock, addr_in) = EOK)
      val () = destroy_sockaddr_in(addr_in)
      val () = assertloc(listen(sock, 5) = EOK)
  in 0 end
