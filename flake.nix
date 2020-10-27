{
  description =
    "A utility to practise calculating the day of the week of random dates";

  outputs = { self, nixpkgs }: {

    defaultPackage.x86_64-linux =
      with import nixpkgs { system = "x86_64-linux"; };
      stdenvNoCC.mkDerivation {
        name = "doomsday";
        src = self;
        buildInputs = [ zig ];
        # some weirdness with XDG_CACHE_HOME here, though it should be fixed
        # in Zig 0.7.0.
        # https://github.com/ziglang/zig/issues/6810#issuecomment-717223951
        doConfigure = false;
        buildPhase = ''
          export XDG_CACHE_HOME=$(mktemp -d)
          mkdir $out
          zig build install --prefix $out -Drelease-safe=true
          rm -rf $XDG_CACHE_HOME
        '';
        installPhase = "true";
      };
  };
}
