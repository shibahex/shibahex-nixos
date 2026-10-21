{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, rustPlatform
, makeWrapper
, copyDesktopItems
, makeDesktopItem
, pkg-config
, meson
, ninja
, wayland-scanner
, cmake
, makeBinaryWrapper
, glslang
, python3
, hwdata
, v4l-utils
, writeShellScriptBin
, symlinkJoin
, # build inputs - gamescope-kbm
  pipewire
, xorg
, wayland
, wayland-protocols
, vulkan-loader
, vulkan-headers
, libavif
, libdrm
, libei
, SDL2
, libdecor
, libinput
, libxkbcommon
, gbenchmark
, pixman
, libcap
, lcms2
, luajit
, seatd
, xwayland
, # build inputs - partydeck
  libarchive
, openssl
, libGL
, fontconfig
, freetype
, dbus
, libevdev
, # runtime PATH deps (wrapProgram)
  bubblewrap
, umu-launcher
, fuse-overlayfs
, # bundled system deps
  gamescope
,
}:

let
  partydeck-icon = fetchurl {
    url = "https://raw.githubusercontent.com/wunnr/partydeck-rs/main/.github/assets/icon.png";
    hash = "sha256-pbhWe+R6TAxW0FPPZfqwJetG8YI+Znyb98VDZjOCsnI=";
  };

  gamescope-kbm-glm = fetchFromGitHub {
    owner = "g-truc";
    repo = "glm";
    rev = "0af55ccecd98d4e5a8d1fad7de25ba429d60e863";
    hash = "sha256-GnGyzNRpzuguc3yYbEFtYLvG+KiCtRAktiN+NvbOICE=";
  };

  gamescope-kbm-stb = fetchFromGitHub {
    owner = "nothings";
    repo = "stb";
    rev = "5736b15f7ea0ffb08dd38af21067c314d6a3aae9";
    hash = "sha256-s2ASdlT3bBNrqvwfhhN6skjbmyEnUgvNOrvhgUSRj98=";
  };

  gamescope-kbm = stdenv.mkDerivation {
    pname = "gamescope-kbm";
    version = "3.x-kbm-unstable-2026-03-11";

    # Bundled wlroots 0.18 doesn't handle LIBINPUT_SWITCH_KEYPAD_SLIDE added in
    # newer libinput. Suppress -Werror=switch rather than patching wlroots.
    NIX_CFLAGS_COMPILE = "-Wno-error=switch";

    src = fetchFromGitHub {
      owner = "partydeck";
      repo = "gamescope";
      rev = "074c4f6f6f07d473af995717cc647e43efef741c";
      fetchSubmodules = true;
      hash = "sha256-IHxM1j2HMf5hC2GjTq4fI3qs3ev/AFwP2CPcyF6203o=";
    };

    postPatch = ''
      cp -r ${gamescope-kbm-glm} subprojects/glm
      chmod -R u+w subprojects/glm
      cp subprojects/packagefiles/glm/meson.build subprojects/glm/meson.build

      cp -r ${gamescope-kbm-stb} subprojects/stb
      chmod -R u+w subprojects/stb
      cp subprojects/packagefiles/stb/meson.build subprojects/stb/meson.build

      patchShebangs subprojects/libdisplay-info/tool/gen-search-table.py || true
      patchShebangs default_extras_install.sh || true
    '';

    nativeBuildInputs = [
      meson
      pkg-config
      ninja
      wayland-scanner
      cmake
      makeBinaryWrapper
      glslang
      python3
      hwdata
      v4l-utils
      (writeShellScriptBin "git" "echo 3.x-kbm")
    ];

    buildInputs = [
      pipewire
      hwdata
      xorg.libX11
      xorg.libxcb
      wayland
      wayland-protocols
      vulkan-loader
      vulkan-headers
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXi
      xorg.libXmu
      xorg.libXrender
      xorg.libXres
      xorg.libXtst
      xorg.libXxf86vm
      libavif
      libdrm
      libei
      SDL2
      libdecor
      libinput
      libxkbcommon
      gbenchmark
      pixman
      libcap
      lcms2
      luajit
      seatd
      xwayland
      xorg.xcbutilwm
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilrenderutil
      xorg.xcbutilcursor
      xorg.xcbutilerrors
    ];

    mesonFlags = [
      (lib.mesonBool "enable_gamescope" true)
      (lib.mesonBool "enable_gamescope_wsi_layer" true)
    ];

    mesonInstallFlags = [ "--skip-subprojects" ];
    strictDeps = true;

    depsBuildBuild = [ pkg-config ];

    postInstall = ''
      mv $out/bin/gamescope $out/bin/gamescope-kbm
    '';

    meta = with lib; {
      description = "gamescope fork with per-player KBM isolation for partydeck";
      homepage = "https://github.com/partydeck/gamescope";
      license = licenses.bsd2;
      platforms = platforms.linux;
    };
  };

  partydeck-bare = rustPlatform.buildRustPackage rec {
    pname = "partydeck-rs";
    version = "0.8.6";

    src = fetchFromGitHub {
      owner = "wunnr";
      repo = "partydeck-rs";
      rev = "v${version}";
      hash = "sha256-BLgaQxmnLaKWo/RFOCpdjwfoYnyHXxoJy1ImJU/8ceI=";
    };

    cargoHash = "sha256-pPbMKyp3e3umhVwZ7Aj3T9RUPPTdZlGYgWUjUdy2YB8=";

    nativeBuildInputs = [
      makeWrapper
      copyDesktopItems
      pkg-config
    ];

    buildInputs = [
      libarchive
      openssl
      libGL
      libxkbcommon
      wayland
      xorg.libX11
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXi
      xorg.libxcb
      SDL2
      fontconfig
      freetype
      dbus
      libevdev
    ];

    desktopItems = [
      (makeDesktopItem {
        name = "partydeck";
        desktopName = "PartyDeck";
        comment = "A split-screen game launcher for Linux";
        exec = "partydeck";
        icon = "partydeck";
        categories = [
          "Game"
          "Utility"
        ];
        keywords = [
          "games"
          "launcher"
          "split-screen"
          "couch"
          "multiplayer"
        ];
      })
    ];

    postInstall = ''
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp ${partydeck-icon} $out/share/icons/hicolor/512x512/apps/partydeck.png

      cp -r $src/res $out/bin/res

      wrapProgram $out/bin/partydeck \
        --prefix PATH : ${
          lib.makeBinPath [
            gamescope-kbm
            bubblewrap
            umu-launcher
            fuse-overlayfs
          ]
        } \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            libxkbcommon
            libGL
            vulkan-loader
            wayland
            xorg.libX11
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
          ]
        } \
        --set-default PARTYDECK_SKIP_UMU_UPDATE "1"
    '';

    meta = with lib; {
      description = "A split-screen game launcher for Linux/SteamOS";
      homepage = "https://github.com/wunnr/partydeck-rs";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      maintainers = with maintainers; [ ];
    };
  };

in
symlinkJoin {
  name = "partydeck-${partydeck-bare.version}";
  paths = [
    partydeck-bare
    gamescope-kbm
    gamescope
    bubblewrap
  ];
  meta = partydeck-bare.meta;
  passthru = { inherit gamescope-kbm; };
}
