
%{
#include <sys/socket.h>
%}

(*** socket library ***)

abst@ype error_t = int

%{
typedef int domain_t;
%}
abst@ype domain_t = int
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
create_sockaddr_in (
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
destroy_sockaddr_in (
  atstype_ptr sa
) {
  free(sa);
}
%}
extern fun create_sockaddr_in(domain : domain_t, addr : int, port : int) : sockaddr_in_t = "mac#create_sockaddr_in"
extern fun destroy_sockaddr_in(sockaddr : sockaddr_in_t) : void = "mac#destroy_sockaddr_in"

//extern fun bind(socket : socket_t, 

abst@ype shutdown_t = int
macdef SHUT_RD = $extval(shutdown_t, "SHUT_RD")
macdef SHUT_WR = $extval(shutdown_t, "SHUT_WR")
macdef SHUT_RDWR = $extval(shutdown_t, "SHUT_RDWR")

extern fun destroy(socket : socket_t, how : shutdown_t) : error_t = "mac#shutdown"

(*** echo! ***)

implement main(argc, argv) = 
  let val sock = create(AF_INET, SOCK_STREAM, DEFAULT_PROTOCOL)
      val addr_in = create_sockaddr_in(AF_INET, 0, htons(8877))
  in 0 end
