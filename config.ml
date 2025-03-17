(* mirage >= 4.9.0 & < 4.10.0 *)

(* Copyright Robur, 2020 *)

open Mirage

let dnsvizor =
  let packages = [
    package "logs" ;
    package "metrics" ;
    package ~min:"6.4.0" ~sublibs:["mirage"] "dns-stub";
    package "dns";
    package "dns-client";
    package "dns-mirage";
    package "dns-resolver";
    package "dns-tsig";
    package "dns-server";
    package ~min:"4.3.1" "mirage-runtime";
  ]
  in
  main ~packages "Unikernel.Main" (stackv4v6 @-> job)

let () =
  register "dns-stub" [ dnsvizor $ generic_stackv4v6 default_network ]
