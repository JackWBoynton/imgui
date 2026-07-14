{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },

  lib ? pkgs.lib,
  stdenv ? pkgs.stdenv,
  cmake ? pkgs.cmake,
  ninja ? pkgs.ninja,

  freetype ? pkgs.freetype or null,
  plutosvg ? pkgs.plutosvg or null,
  stb ? pkgs.stb or null,

  glfw ? pkgs.glfw or null,
  libGL ? pkgs.libGL or null,
  SDL2 ? pkgs.SDL2 or null,
  sdl3 ? pkgs.sdl3 or null,
  vulkan-headers ? pkgs.vulkan-headers or null,
  vulkan-loader ? pkgs.vulkan-loader or null,

  IMGUI_UPSTREAM_VERSION ? "1.92.6",

  IMGUI_BUILD_ALLEGRO5_BINDING ? false,
  IMGUI_BUILD_ANDROID_BINDING ? stdenv.hostPlatform.isAndroid,
  IMGUI_BUILD_DX9_BINDING ? false,
  IMGUI_BUILD_DX10_BINDING ? false,
  IMGUI_BUILD_DX11_BINDING ? false,
  IMGUI_BUILD_DX12_BINDING ? false,

  # Old Conan package built GLFW on macOS too.
  IMGUI_BUILD_GLFW_BINDING ? !stdenv.hostPlatform.isAndroid,
  IMGUI_BUILD_GLUT_BINDING ? false,
  IMGUI_BUILD_METAL_BINDING ? stdenv.hostPlatform.isDarwin,

  IMGUI_BUILD_SDL2_BINDING ? false,
  IMGUI_BUILD_SDL2_RENDERER_BINDING ? false,

  IMGUI_BUILD_SDL3_BINDING ? false,
  IMGUI_BUILD_SDL3_RENDERER_BINDING ? IMGUI_BUILD_SDL3_BINDING,
  IMGUI_BUILD_SDLGPU3_BINDING ?
    IMGUI_BUILD_SDL3_BINDING && lib.versionAtLeast IMGUI_UPSTREAM_VERSION "1.91.8",

  IMGUI_BUILD_OPENGL2_BINDING ? false,
  IMGUI_BUILD_OPENGL3_BINDING ?
    !stdenv.hostPlatform.isDarwin
    && (IMGUI_BUILD_SDL3_BINDING || IMGUI_BUILD_GLFW_BINDING || IMGUI_BUILD_GLUT_BINDING),

  IMGUI_BUILD_OSX_BINDING ? false,
  IMGUI_BUILD_VULKAN_BINDING ? false,
  IMGUI_BUILD_WIN32_BINDING ? false,

  # SVG path uses imgui_freetype.cpp too, so SVG implies FreeType.
  IMGUI_FREETYPE_SVG ? true,
  IMGUI_FREETYPE ? IMGUI_FREETYPE_SVG,
  IMGUI_FREETYPE_LUNASVG ? false,
  IMGUI_USE_WCHAR32 ? true,
  IMGUI_TEST_ENGINE ? false,

  IMGUI_LINK_GLVND ?
    !stdenv.hostPlatform.isWindows
    && !stdenv.hostPlatform.isDarwin
    && (IMGUI_BUILD_OPENGL2_BINDING || IMGUI_BUILD_OPENGL3_BINDING),
}:

stdenv.mkDerivation {
  pname = "imgui";
  version = "${IMGUI_UPSTREAM_VERSION}-instronimbus";

  outputs = [
    "out"
    "lib"
  ];

  src = lib.cleanSource ./.;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  propagatedBuildInputs =
    lib.optionals IMGUI_LINK_GLVND [ libGL ]
    ++ lib.optionals IMGUI_BUILD_GLFW_BINDING [ glfw ]
    ++ lib.optionals IMGUI_BUILD_SDL3_BINDING [ sdl3 ]
    ++ lib.optionals IMGUI_BUILD_SDL2_BINDING [ SDL2 ]
    ++ lib.optionals IMGUI_BUILD_VULKAN_BINDING [
      vulkan-headers
      vulkan-loader
    ]
    ++ lib.optionals (IMGUI_FREETYPE || IMGUI_FREETYPE_SVG) [ freetype ]
    ++ lib.optionals IMGUI_FREETYPE_SVG [ plutosvg ]
    ++ lib.optionals IMGUI_TEST_ENGINE [ stb ];

  cmakeFlags = [
    (lib.cmakeBool "IMGUI_BUILD_ALLEGRO5_BINDING" IMGUI_BUILD_ALLEGRO5_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_ANDROID_BINDING" IMGUI_BUILD_ANDROID_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_DX9_BINDING" IMGUI_BUILD_DX9_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_DX10_BINDING" IMGUI_BUILD_DX10_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_DX11_BINDING" IMGUI_BUILD_DX11_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_DX12_BINDING" IMGUI_BUILD_DX12_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_GLFW_BINDING" IMGUI_BUILD_GLFW_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_GLUT_BINDING" IMGUI_BUILD_GLUT_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_METAL_BINDING" IMGUI_BUILD_METAL_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_OPENGL2_BINDING" IMGUI_BUILD_OPENGL2_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_OPENGL3_BINDING" IMGUI_BUILD_OPENGL3_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_OSX_BINDING" IMGUI_BUILD_OSX_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_SDL2_BINDING" IMGUI_BUILD_SDL2_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_SDL2_RENDERER_BINDING" IMGUI_BUILD_SDL2_RENDERER_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_SDL3_BINDING" IMGUI_BUILD_SDL3_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_SDL3_RENDERER_BINDING" IMGUI_BUILD_SDL3_RENDERER_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_SDLGPU3_BINDING" IMGUI_BUILD_SDLGPU3_BINDING)

    (lib.cmakeBool "IMGUI_BUILD_VULKAN_BINDING" IMGUI_BUILD_VULKAN_BINDING)
    (lib.cmakeBool "IMGUI_BUILD_WIN32_BINDING" IMGUI_BUILD_WIN32_BINDING)

    (lib.cmakeBool "IMGUI_FREETYPE" IMGUI_FREETYPE)
    (lib.cmakeBool "IMGUI_FREETYPE_LUNASVG" IMGUI_FREETYPE_LUNASVG)
    (lib.cmakeBool "IMGUI_USE_WCHAR32" IMGUI_USE_WCHAR32)
    (lib.cmakeBool "IMGUI_FREETYPE_SVG" IMGUI_FREETYPE_SVG)
    (lib.cmakeBool "IMGUI_TEST_ENGINE" IMGUI_TEST_ENGINE)
  ];

  meta = {
    broken =
      IMGUI_BUILD_SDL2_BINDING
      || IMGUI_BUILD_SDL2_RENDERER_BINDING
      || IMGUI_FREETYPE_LUNASVG
      || IMGUI_BUILD_DX9_BINDING
      || IMGUI_BUILD_DX10_BINDING
      || IMGUI_BUILD_DX11_BINDING
      || IMGUI_BUILD_DX12_BINDING
      || IMGUI_BUILD_WIN32_BINDING
      || IMGUI_BUILD_ALLEGRO5_BINDING
      || IMGUI_BUILD_ANDROID_BINDING;

    description = "Bloat-free graphical user interface for C++ with minimal dependencies";
    homepage = "https://github.com/ocornut/imgui";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      jackwboynton
    ];
    platforms = lib.platforms.all;
  };
}
