module K = struct
  open Cmdliner
  let dns_upstream =
    let doc = Arg.info ~doc:"Upstream DNS resolver" ["dns-upstream"] in
    Mirage_runtime.register_arg Arg.(value & (opt (some string) None doc))

  let dns_cache =
    let doc = Arg.info ~doc:"DNS cache size" ["dns-cache"] in
    Mirage_runtime.register_arg Arg.(value & (opt (some int) None doc))
end

open Lwt.Infix

module Main (S : Tcpip.Stack.V4V6) = struct

  module Stub = Dns_stub_mirage.Make(S)

  let start s =
    let nameservers =
      Option.map (fun ns -> [ ns ]) (K.dns_upstream ())
    and primary_t =
      (* setup DNS server state: *)
      Dns_server.Primary.create ~rng:Mirage_crypto_rng.generate Dns_trie.empty
    in
    Stub.H.connect_device s >>= fun happy_eyeballs ->
    (* setup stub forwarding state and IP listeners: *)
    (try
       Stub.create ?cache_size:(K.dns_cache ()) ?nameservers primary_t ~happy_eyeballs s
     with
       Invalid_argument a ->
       Logs.err (fun m -> m "error %s" a);
       exit Mirage_runtime.argument_error) >>= fun (_stub_t : Stub.t) ->
    (* Since {Stub.create} registers UDP + TCP listeners asynchronously there
       is no Lwt task. *)
    S.listen s
end
