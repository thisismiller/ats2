staload either = "lib/either.sats"
staload errno = "lib/errno.sats"

%{
#include <sys/socket.h>
%}

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
castfn int_of_socket(socket : socket_t):<> int
castfn socket_of_int(i : int):<> socket_t

fun create(domain : domain_t, type_ : type_t, protocol : protocol_t) : socket_t = "mac#socket"

%{
#include <arpa/inet.h>
%}
fun htons(i : int) : int = "mac#htons"

absviewt@ype sockaddr_in_t = $extype"atstype_ptr"
%{
#include <netinet/in.h>

atstype_ptr ats_create_sockaddr_in (domain_t af, in_addr_t inp, in_port_t port);
atstype_void ats_destroy_sockaddr_in (atstype_ptr sa);
%}
fun create_sockaddr_in(domain : domain_t, addr : int, port : int) : sockaddr_in_t = "mac#ats_create_sockaddr_in"
fun destroy_sockaddr_in(sockaddr : sockaddr_in_t) : void = "mac#ats_destroy_sockaddr_in"

%{
errno_t ats_bind_sockaddr_in (int sock, atstype_ptr sockaddr);
%}
fun bind(socket : !socket_t, sockaddr : !sockaddr_in_t) : $errno.t = "mac#ats_bind_sockaddr_in"

%{
errno_t ats_listen (int sock , int backlog);
%}
fun listen(socket : !socket_t, backlog : int ) : $errno.t = "mac#ats_listen"

%{
atstype_int ats_accept (int socket);
%}
fun accept(socket : !socket_t) : $either.VT (socket_t, $errno.t)

abst@ype shutdown_t = int
macdef SHUT_RD = $extval(shutdown_t, "SHUT_RD")
macdef SHUT_WR = $extval(shutdown_t, "SHUT_WR")
macdef SHUT_RDWR = $extval(shutdown_t, "SHUT_RDWR")

%{
errno_t ats_shutdown (int socket, int how);
%}
fun destroy(socket : socket_t, how : shutdown_t) : $errno.t = "mac#ats_shutdown"
