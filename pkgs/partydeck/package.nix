{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, makeBinaryWrapper
, pkg-config
, p7zip
, bubblewrap
, fetchurl
, fontconfig
, fuse-overlayfs
, gamescope-kbm
, libGL
, libx11
, libxcursor
, libxi
, libxkbcommon
, libxrandr
, openssl
, umu-launcher
, wayland
, xdg-utils
,
}:
let
  gbeVersion = "release-2026_03_10";
  gbe-linux-src = fetchurl {
    url = "https://github.com/Detanup01/gbe_fork/releases/download/${gbeVersion}/emu-linux-release.tar.bz2";
    hash = "sha256-AyUAyhALcv0tqpTuwyY898b+Y0h2I/nijXDu5BpYuwE=";
  };
  gbe-win-src = fetchurl {
    url = "https://github.com/Detanup01/gbe_fork/releases/download/${gbeVersion}/emu-win-release.7z";
    hash = "sha256-D2ekISqk5qcfhIeaOgD2dcsqjEPhPjjgsnq1yeal5l8=";
  };
  goldberg-emu = stdenv.mkDerivation {
    pname = "goldberg-emu";
    version = gbeVersion;
    src = gbe-linux-src;
    nativeBuildInputs = [ p7zip ];
    sourceRoot = ".";
    unpackPhase = ''
      mkdir -p linux win
      tar -xf ${gbe-linux-src} -C linux
      7z x -aoa ${gbe-win-src} -owin
    '';
    installPhase = ''
      mkdir -p $out/share/goldberg/{linux32,linux64,win}
      cp linux/release/regular/x32/steamclient.so  $out/share/goldberg/linux32/
      cp linux/release/regular/x64/steamclient.so  $out/share/goldberg/linux64/
      cp win/release/steamclient_experimental/steamclient.dll        \
         win/release/steamclient_experimental/steamclient64.dll      \
         win/release/steamclient_experimental/GameOverlayRenderer.dll   \
         win/release/steamclient_experimental/GameOverlayRenderer64.dll \
         $out/share/goldberg/win/
    '';
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "partydeck";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "partydeck";
    repo = "partydeck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BLgaQxmnLaKWo/RFOCpdjwfoYnyHXxoJy1ImJU/8ceI=";
  };

  cargoHash = "sha256-pPbMKyp3e3umhVwZ7Aj3T9RUPPTdZlGYgWUjUdy2YB8=";

  __structuredAttrs = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    fontconfig
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    openssl
    wayland
  ];

  runtimePath = [
    bubblewrap
    fuse-overlayfs
    gamescope-kbm
    umu-launcher
    xdg-utils
  ];

  prePatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail 'version = "0.8.5"' 'version = "${finalAttrs.version}"'
  '';

  postPatch = ''
    substituteInPlace src/paths.rs \
      --replace-fail 'PathBuf::from("/usr/share/partydeck")' \
                     'PathBuf::from("${placeholder "out"}/share/partydeck")'
  '';

  postInstall = ''
    install -Dm644 res/*.js -t $out/share/partydeck
    install -Dm644 res/*.png -t $out/share/partydeck
    install -Dm755 res/GamingModeLauncher.sh -t $out/share/partydeck
    mkdir -p $out/share/partydeck/goldberg
    ln -s ${goldberg-emu}/share/goldberg/linux32 $out/share/partydeck/goldberg/linux32
    ln -s ${goldberg-emu}/share/goldberg/linux64 $out/share/partydeck/goldberg/linux64
    ln -s ${goldberg-emu}/share/goldberg/win     $out/share/partydeck/goldberg/win
    # Symlink so exe_dir/res/ resolves to share/partydeck/
    ln -s $out/share/partydeck $out/bin/res
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/partydeck \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:/run/opengl-driver/lib" \
      --prefix PATH : "${lib.makeBinPath finalAttrs.runtimePath}"
  '';

  meta = {
    description = "Split-screen game launcher for Linux and SteamOS";
    homepage = "https://github.com/partydeck/partydeck";
    changelog = "https://github.com/partydeck/partydeck/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "partydeck";
    maintainers = [ lib.maintainers.imalison ];
    platforms = lib.platforms.linux;
  };
})
