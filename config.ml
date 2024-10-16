(* mirage >= 4.8.0 & < 4.9.0 *)

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
  main
    ~packages
    "Unikernel.Main"
    (random @-> pclock @-> mclock @-> time @-> stackv4v6 @-> job)

let () =
  register "dns-stub" [
    dnsvizor $ default_random $ default_posix_clock
    $ default_monotonic_clock $ default_time
    $ generic_stackv4v6 default_network ]
