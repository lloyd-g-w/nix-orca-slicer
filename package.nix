{
  lib,
  stdenvNoCC,
  makeWrapper,
  mesa,
  orca-slicer,
  withNvidiaGLWorkaround ? true,
}:
stdenvNoCC.mkDerivation {
  pname = "orca-slicer-wrapped";
  inherit (orca-slicer) version;

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    makeWrapper ${lib.getExe orca-slicer} $out/bin/orca-slicer \
      --set WEBKIT_DISABLE_COMPOSITING_MODE 1 \
      ${
      lib.optionalString withNvidiaGLWorkaround ''
        --set __GLX_VENDOR_LIBRARY_NAME mesa \
        --set __EGL_VENDOR_LIBRARY_FILENAMES ${mesa}/share/glvnd/egl_vendor.d/50_mesa.json \
        --set MESA_LOADER_DRIVER_OVERRIDE zink \
        --set GALLIUM_DRIVER zink \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1
      ''
    }

    runHook postInstall
  '';

  meta =
    orca-slicer.meta
    // {
      mainProgram = "orca-slicer";
    };
}
