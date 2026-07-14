cmake_minimum_required(VERSION 3.16)
project(imgui CXX)

if(APPLE)
    set(CMAKE_CXX_STANDARD 11)
    enable_language(OBJCXX)
endif()

include(GNUInstallDirs) # Defines CMAKE_INSTALL_INCLUDEDIR if not set

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_include_directories(
    ${PROJECT_NAME}
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR};${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine>"
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_demo.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_draw.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_tables.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_widgets.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp
)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)

if(IMGUI_BUILD_ALLEGRO5_BINDING)
    find_package(Allegro CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PRIVATE Allegro::allegro Allegro::allegro_ttf Allegro::allegro_font Allegro::allegro_main)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_allegro5.cpp)
endif()

if(IMGUI_BUILD_ANDROID_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_android.cpp)
endif()

if(IMGUI_BUILD_DX9_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx9.cpp)
endif()

if(IMGUI_BUILD_DX10_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx10.cpp)
endif()

if(IMGUI_BUILD_DX11_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx11.cpp)
endif()

if(IMGUI_BUILD_DX12_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx12.cpp)
endif()

if(IMGUI_BUILD_GLFW_BINDING)
    if(NOT EMSCRIPTEN)
        find_package(glfw3 CONFIG REQUIRED)
        target_link_libraries(${PROJECT_NAME} PUBLIC glfw)
    endif()
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glfw.cpp)
    target_compile_definitions(${PROJECT_NAME} PRIVATE GLFW_INCLUDE_NONE)
endif()

if(IMGUI_BUILD_GLUT_BINDING)
    find_package(GLUT REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC GLUT::GLUT)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glut.cpp)
endif()

if(IMGUI_BUILD_METAL_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.mm)
    set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.mm PROPERTIES COMPILE_FLAGS -fobjc-weak)

    target_link_libraries(${PROJECT_NAME} PUBLIC
        "-framework Metal"
        "-framework MetalKit"
        "-framework QuartzCore"
        "-framework AppKit"
        "-framework Cocoa"
        "-framework IOKit"
        "-framework CoreFoundation"
        "-framework CoreVideo"
    )
endif()

if(IMGUI_BUILD_OPENGL2_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl2.cpp)
endif()

if(IMGUI_BUILD_OPENGL3_BINDING)
    if(APPLE AND (CMAKE_SYSTEM_NAME MATCHES "iOS"))
        target_compile_definitions(${PROJECT_NAME} PRIVATE IMGUI_IMPL_OPENGL_ES3)
        target_link_libraries(${PROJECT_NAME} PUBLIC -framework OpenGLES)
    elseif(ANDROID)
        target_compile_definitions(${PROJECT_NAME} PRIVATE IMGUI_IMPL_OPENGL_ES3)
        find_path(OPENGL_INCLUDE_DIR NAMES GLES3/gl3.h REQUIRED)
        target_include_directories(${PROJECT_NAME} PRIVATE ${OPENGL_INCLUDE_DIR})
    endif()
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_BUILD_OSX_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_osx.mm)
endif()

if(IMGUI_BUILD_SDL3_BINDING)
    # Under Emscripten, SDL3 is provided by the sdl3 port via link flags
    # (--use-port=sdl3), not as a CMake package.
    if(NOT EMSCRIPTEN)
        find_package(SDL3 CONFIG REQUIRED)
        target_link_libraries(${PROJECT_NAME} PUBLIC SDL3::SDL3)
    else()
        target_compile_options(${PROJECT_NAME} PUBLIC "--use-port=sdl3")
    endif()
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdl3.cpp)
endif()

if(IMGUI_BUILD_SDLGPU3_BINDING)
    find_package(SDL3 CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC SDL3::SDL3)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlgpu3.cpp)
endif()

if(IMGUI_BUILD_SDL3_RENDERER_BINDING)
    find_package(SDL3 CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC SDL3::SDL3)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlrenderer3.cpp)
endif()

if(IMGUI_BUILD_VULKAN_BINDING)
    find_package(Vulkan REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC Vulkan::Vulkan)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_vulkan.cpp)
endif()

if(IMGUI_BUILD_WIN32_BINDING)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_win32.cpp)
endif()

if(IMGUI_BUILD_WEBGPU_BINDING)
    find_package(Dawn CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC dawn::webgpu_dawn)
    target_compile_definitions(${PROJECT_NAME} PRIVATE IMGUI_IMPL_WEBGPU_BACKEND_DAWN)
    list(APPEND WGPU_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_wgpu.cpp)
    target_sources(${PROJECT_NAME} PRIVATE ${WGPU_SRCS})
    if(APPLE)
        set_source_files_properties(${WGPU_SRCS} PROPERTIES LANGUAGE OBJCXX)
        target_link_libraries(${PROJECT_NAME} PUBLIC "-framework Foundation")
    endif()
endif()

if(IMGUI_FREETYPE OR IMGUI_FREETYPE_SVG)
    find_package(Freetype MODULE REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC Freetype::Freetype)
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.cpp)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_ENABLE_FREETYPE)
endif()

if(IMGUI_FREETYPE_SVG)
    find_package(plutosvg CONFIG REQUIRED)
    target_link_libraries(${PROJECT_NAME} PUBLIC plutosvg::plutosvg)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_ENABLE_FREETYPE_PLUTOSVG)
endif()

if(IMGUI_USE_WCHAR32)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_USE_WCHAR32)
endif()

if(IMGUI_TEST_ENGINE)
    find_path(Stb_INCLUDE_DIR NAMES stb/stb_image.h stb_image.h REQUIRED)

    add_library(imgui_test_engine STATIC
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_capture_tool.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_context.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_coroutine.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_engine.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_exporters.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_perftool.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_ui.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_utils.cpp
    )
    add_library(imgui_test_engine::imgui_test_engine ALIAS imgui_test_engine)

    target_include_directories(imgui_test_engine
        PUBLIC
            "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine>"
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
        PRIVATE
            ${Stb_INCLUDE_DIR}
            ${Stb_INCLUDE_DIR}/stb
    )
    target_link_libraries(imgui_test_engine PUBLIC imgui::imgui)
    target_compile_features(imgui_test_engine PUBLIC cxx_std_11)
    target_compile_definitions(imgui_test_engine PUBLIC IMGUI_ENABLE_TEST_ENGINE)
    target_compile_definitions(${PROJECT_NAME} PUBLIC IMGUI_ENABLE_TEST_ENGINE)

    install(
        TARGETS imgui_test_engine
        EXPORT imgui_test_engine_target
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )

    if(NOT IMGUI_SKIP_HEADERS)
        install(
            FILES
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_capture_tool.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_context.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_coroutine.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_engine.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_exporters.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_imconfig.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_internal.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_perftool.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_ui.h
                ${CMAKE_CURRENT_SOURCE_DIR}/test-engine/imgui_test_engine/imgui_te_utils.h
            DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        )
    endif()

    include(CMakePackageConfigHelpers)
    configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/imgui_test_engine-config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/imgui_test_engine-config.cmake"
        INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/imgui_test_engine"
    )
    install(
        FILES "${CMAKE_CURRENT_BINARY_DIR}/imgui_test_engine-config.cmake"
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/imgui_test_engine"
    )
    install(
        EXPORT imgui_test_engine_target
        NAMESPACE imgui_test_engine::
        FILE imgui_test_engine-targets.cmake
        DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/imgui_test_engine"
    )
endif()

list(REMOVE_DUPLICATES BINDINGS_SOURCES)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
    ARCHIVE
        COMPONENT Development
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY
        COMPONENT Runtime
        NAMELINK_COMPONENT Development
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME
        COMPONENT Runtime
        DESTINATION ${CMAKE_INSTALL_BINDIR}
)

foreach(BINDING_TARGET ${BINDING_TARGETS})
    install(
        TARGETS ${BINDING_TARGET}
        EXPORT ${PROJECT_NAME}_target
        ARCHIVE
            COMPONENT Development
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY
            COMPONENT Runtime
            NAMELINK_COMPONENT Development
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME
            COMPONENT Runtime
            DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endforeach()

if(NOT IMGUI_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_internal.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_textedit.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_rectpack.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_truetype.h
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )

    install(DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}/backends
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        FILES_MATCHING PATTERN "*.h"
    )

    if(IMGUI_BUILD_ALLEGRO5_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_allegro5.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if (IMGUI_BUILD_ANDROID_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_android.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_DX9_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx9.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_DX10_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx10.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_DX11_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx11.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_DX12_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_dx12.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_GLFW_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glfw.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_GLUT_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_glut.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_METAL_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_metal.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_OPENGL2_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl2.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_OPENGL3_BINDING)
        install(
            FILES
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3.h
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_opengl3_loader.h
            DESTINATION
                include
        )
    endif()

    if(IMGUI_BUILD_OSX_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_osx.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_SDL3_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdl3.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_SDLGPU3_BINDING)
        install(
            FILES
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlgpu3.h
                ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlgpu3_shaders.h
            DESTINATION
                ${CMAKE_INSTALL_INCLUDEDIR}
        )
    endif()

    if(IMGUI_BUILD_SDL3_RENDERER_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_sdlrenderer3.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_VULKAN_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_vulkan.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_WIN32_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_win32.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_BUILD_WEBGPU_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/backends/imgui_impl_wgpu.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

    if(IMGUI_FREETYPE)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    endif()

endif()

set(IMGUI_CONFIG_FIND_DEPS "")
if(IMGUI_FREETYPE OR IMGUI_FREETYPE_SVG)
    string(APPEND IMGUI_CONFIG_FIND_DEPS "find_dependency(Freetype MODULE)\n")
endif()
if(IMGUI_FREETYPE_SVG)
    string(APPEND IMGUI_CONFIG_FIND_DEPS "find_dependency(plutosvg CONFIG)\n")
endif()
if(IMGUI_BUILD_GLFW_BINDING)
    string(APPEND IMGUI_CONFIG_FIND_DEPS "find_dependency(glfw3 CONFIG)\n")
endif()
if (IMGUI_BUILD_VULKAN_BINDING)
    string(APPEND IMGUI_CONFIG_FIND_DEPS "find_dependency(Vulkan)\n")
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file(imgui-config.cmake.in imgui-config.cmake INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/imgui-config.cmake DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-targets.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
