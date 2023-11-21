# asdf2nix flake template

This repository contains a simple flake template for installing development dependencies from a local `.tool-versions` file as used by [asdf](https://asdf-vm.com/).

The template is my first try with the nix language and was created to assist with some nix environment needs in a very ad-hoc manner.
Nevertheless it might work for you, too, and contributions are welcome.

## How to use it

Add the flake.nix file from the template:

```bash
nix flake init -t github:kzemek/asdf2nix
```

You should now be able to get into a shell with your tools installed with:

```bash
nix develop
```

## How it works

The flake reads `.tool-versions` and searches for the mentioned packages in the current nixpkgs snapshot.
For each specified dependency it tries to resolve to the closest version as possible, e.g. for `erlang 25.1.3` it will resolve to the first matching package from the following list:

```nix
[erlang_25_1_3 erlang2513 erlang_25_1 erlang251 erlang_25 erlang25 erlang]
```

which at the time of writing will be `erlang_25`.

## Settings & default packages

Some defaults are specified in the flake and should be modified as needed, e.g.:
```
      pkgNameReplacements = {
        postgres = "postgresql";
        rabbitmq = "rabbitmq-server";
      };
      defaultPackages = {
        python = "python310";
        poetry = "poetry";
      };
```
will search for `postgresql` package in nixpkgs for a `postgres` `.tool-versions` entry, and will attempt to install `python310` and `poetry` even if they're not mentioned in `.tool-versions`.
Note that any `python` dependency from `.tool-versions` will override that default.
