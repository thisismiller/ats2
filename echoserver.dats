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
staload _ = "prelude/DATS/array.dats" (* rv > 0 *)

overload = with $errno.eq_errno_errno


(*** echo! ***)

implement main(argc, argv) = 
  let val sock = $socket.create($socket.AF_INET, $socket.SOCK_STREAM, $socket.DEFAULT_PROTOCOL)
      val addr_in = $socket.create_sockaddr_in($socket.AF_INET, 0, $socket.htons(8877))
      val () = assertloc($socket.bind(sock, addr_in) = $errno.EOK)
      val () = $socket.destroy_sockaddr_in(addr_in)
      val () = assertloc($socket.listen(sock, 5) = $errno.EOK)
      val r = $socket.accept(sock)
      val () = case+ r of
               | $either.Left_vt (nsock) =>
                      let
                        val size = i2sz(512) : size_t 512
                        val (pfat, pfgc | ptr) = array_ptr_alloc<char>(size)
                        val n_err = $socket.recv(pfat | nsock, ptr, size)
                        val m_err = case+ n_err of
                                    | $either.Left_vt(recvd) => $socket.destroy_size_either(
                                            $socket.send(pfat | nsock, ptr, recvd))
                                    | $either.Right_vt(err) => assertloc(false)
                        val () = $socket.destroy_size_either(n_err)
                        val () = array_ptr_free(pfat, pfgc | ptr)
                      in
                        ()
                      end
               | $either.Right_vt (err) => assertloc(false)
      val () = $socket.destroy_accept_either(r)
      val () = assertloc($socket.destroy(sock, $socket.SHUT_RDWR) = $errno.EOK)
  in 0 end
