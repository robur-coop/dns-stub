## DNS stub - a DNS stub resolver

This is a MirageOS unikernel which listens for DNS requests in a local network. The DNS requests are resolved, and the reply is returned to the client.

## Installation from source

To install this unikernel from source, you need to have
[opam](https://opam.ocaml.org) (>= 2.1.0) and
[ocaml](https://ocaml.org) (>= 4.12.0) installed. Also,
[mirage](https://mirage.io) is required (>= 4.7.0). Please follow the
[installation instructions](https://mirage.io/wiki/install).

The following steps will clone this git repository and compile the unikernel:

```bash
$ git clone https://github.com/robur-coop/dns-stub.git
$ mirage configure -t <your-favourite-target>
$ make depend
$ make build
```

## Installing as binary

Browse the most recent builds [here](https://builds.robur.coop/job/dns-stub).

## Questions?

Please open an issue if you have questions, feature requests, or comments.
