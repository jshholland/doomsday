{ mkDerivation, base, clock, random, stdenv, lib }:
mkDerivation {
  pname = "doomsday";
  version = "0.2.0.0";
  src = lib.cleanSource ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base clock random ];
  homepage = "https://github.com/jshholland/doomsday#readme";
  description = "Practise calculating day of week";
  license = stdenv.lib.licenses.bsd3;
}
