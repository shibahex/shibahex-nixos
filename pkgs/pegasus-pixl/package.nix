{ lib
, fetchFromGitHub
, stdenv
, cmake
, SDL2
, sqlite
, libsForQt5
,
}:

stdenv.mkDerivation {
  pname = "pegasus-frontend";
  version = "0-unstable-2024-11-11";

  src = fetchFromGitHub {
    owner = "pixl-os";
    repo = "pegasus-frontend";
    rev = "pixL-master";
    fetchSubmodules = true;
    hash = "";
  };

  nativeBuildInputs = [
    cmake
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs =
    (with libsForQt5; [
      qtbase
      qtmultimedia
      qtsvg
      qtgraphicaleffects
      qtx11extras
    ])
    ++ [
      sqlite
      SDL2
    ];

  meta = {
    description = "Cross platform, customizable graphical frontend for launching emulators and managing your game collection";
    mainProgram = "pegasus-fe";
    homepage = "https://pegasus-frontend.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ tengkuizdihar ];
    platforms = lib.platforms.linux;
  };
}
