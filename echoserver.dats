staload either = "lib/either.sats"
staload "lib/either.dats"
staload errno = "lib/errno.sats"
staload socket = "lib/socket.sats"
dynload "lib/either.sats"
dynload "lib/either.dats"
dynload "lib/errno.sats"
dynload "lib/errno.dats"
dynload "lib/socket.sats"
dynload "lib/socket.dats"

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


(*** echo! ***)

implement main(argc, argv) = 
  let val sock = $socket.create($socket.AF_INET, $socket.SOCK_STREAM, $socket.DEFAULT_PROTOCOL)
      val addr_in = $socket.create_sockaddr_in($socket.AF_INET, 0, $socket.htons(8877))
      val () = assertloc($socket.bind(sock, addr_in) = $errno.EOK)
      val () = $socket.destroy_sockaddr_in(addr_in)
      val () = assertloc($socket.listen(sock, 5) = $errno.EOK)
      val r = $socket.accept(sock)
      val () = case+ r of
               (* Why is the type annotation of nsock needed to compile? *)
               | $either.Left_vt (nsock : $socket.socket_t) =>
                      assertloc($socket.destroy(nsock, $socket.SHUT_RDWR) = $errno.EOK)
               | $either.Right_vt (err) => assertloc(false)
      val () = free_boxed_vt(r)
      val () = assertloc($socket.destroy(sock, $socket.SHUT_RDWR) = $errno.EOK)
  in 0 end
