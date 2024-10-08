module K = struct
  open Cmdliner
  let dns_upstream =
    let doc = Arg.info ~doc:"Upstream DNS resolver" ["dns-upstream"] in
    Arg.(value & (opt (some string) None doc))

  let dns_cache =
    let doc = Arg.info ~doc:"DNS cache size" ["dns-cache"] in
    Arg.(value & (opt (some int) None doc))
end

open Lwt.Infix

module Main (R : Mirage_crypto_rng_mirage.S) (P : Mirage_clock.PCLOCK)
    (M : Mirage_clock.MCLOCK)
    (Time : Mirage_time.S) (S : Tcpip.Stack.V4V6) = struct

  module Stub = Dns_stub_mirage.Make(R)(Time)(P)(M)(S)

  let start () () () () s dns_upstream cache_size =
    let nameservers =
      Option.map (fun ns -> [ ns ]) dns_upstream
    and primary_t =
      (* setup DNS server state: *)
      Dns_server.Primary.create ~rng:Mirage_crypto_rng.generate Dns_trie.empty
    in
    Stub.H.connect_device s >>= fun happy_eyeballs ->
    (* setup stub forwarding state and IP listeners: *)
    (try
       Stub.create ?cache_size ?nameservers primary_t ~happy_eyeballs s
     with
       Invalid_argument a ->
       Logs.err (fun m -> m "error %s" a);
       exit Mirage_runtime.argument_error) >>= fun (_stub_t : Stub.t) ->
    (* Since {Stub.create} registers UDP + TCP listeners asynchronously there
       is no Lwt task. *)
    S.listen s
end
