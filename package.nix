{
  lib,
  appimageTools,
  fetchurl,
  makeWrapper,
  runCommand,
  bzip2,
  webkitgtk_4_1,
  libsoup_3,
  glib-networking,
  libmspack,
  gdk-pixbuf,
  gtk3,
  adwaita-icon-theme,
  hicolor-icon-theme,
  shared-mime-info,
  librsvg,
  libsecret,
  libxkbcommon,
  libGL,
  vulkan-loader,
  mesa,
}: let
  pname = "orca-slicer";
  version = "2.3.2";

  src = fetchurl {
    url = "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_V${version}.AppImage";

    # If this fails with a hash mismatch, replace this with the "got: sha256-..." value.
    hash = "sha256-xkM2zuw32UF2bmdcuqr1Ek4YRAK/GBd/v4G6UQJzStg=";
  };

  bz2Compat = runCommand "libbz2-1.0-compat" {} ''
    mkdir -p $out/lib
    ln -s ${bzip2.out}/lib/libbz2.so.1 $out/lib/libbz2.so.1.0
  '';

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  xdgDataDirs = lib.makeSearchPath "share" [
    adwaita-icon-theme
    hicolor-icon-theme
    shared-mime-info
    gdk-pixbuf
    gtk3
  ];
in
  appimageTools.wrapType2 {
    inherit pname version src;

    nativeBuildInputs = [
      makeWrapper
    ];

    extraPkgs = pkgs: [
      webkitgtk_4_1
      libsoup_3
      glib-networking
      libmspack
      gdk-pixbuf
      gtk3
      adwaita-icon-theme
      hicolor-icon-theme
      shared-mime-info
      librsvg
      libsecret
      libxkbcommon
      libGL
      vulkan-loader
      mesa
      bzip2
    ];

    extraInstallCommands = ''
      if [ -f ${appimageContents}/OrcaSlicer.desktop ]; then
        install -m 444 -D ${appimageContents}/OrcaSlicer.desktop \
          $out/share/applications/orca-slicer.desktop
        substituteInPlace $out/share/applications/orca-slicer.desktop \
          --replace-fail "Exec=AppRun" "Exec=orca-slicer" \
          --replace-fail "Icon=OrcaSlicer" "Icon=orca-slicer"
      fi

      if [ -f ${appimageContents}/OrcaSlicer.png ]; then
        install -m 444 -D ${appimageContents}/OrcaSlicer.png \
          $out/share/icons/hicolor/256x256/apps/orca-slicer.png
      fi

      wrapProgram $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : "${bz2Compat}/lib" \
        --set GDK_PIXBUF_MODULE_FILE "${gdk-pixbuf}/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache" \
        --prefix XDG_DATA_DIRS : "${xdgDataDirs}" \
        --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1
    '';

    meta = {
      description = "G-code generator for 3D printers";
      homepage = "https://github.com/OrcaSlicer/OrcaSlicer";
      license = lib.licenses.agpl3Only;
      mainProgram = "orca-slicer";
      platforms = ["x86_64-linux"];
    };
  }
