staload stdio = "libc/SATS/stdio.sats"

implement main(argc, argv) = let
  val _ = $stdio.puts("hello")
in 0 end
