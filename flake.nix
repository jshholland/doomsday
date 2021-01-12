{
  description =
    "A utility to practise calculating the day of the week of random dates";

  outputs = { self, nixpkgs }: {
    overlay = final: prev: {
      doomsday = with final;
        stdenvNoCC.mkDerivation {
          name = "doomsday";
          src = self;
          buildInputs = [ zig ];
          doConfigure = false;
          buildPhase = ''
            export XDG_CACHE_HOME=cachedir
            mkdir $out
            zig build install --prefix $out -Drelease-safe=true
          '';
          installPhase = "true";
        };
    };

    defaultPackage.x86_64-linux =
      (import nixpkgs { system = "x86_64-linux"; overlays = [ self.overlay ]; }).doomsday;
  };
}
