# -*- python -*-
load("@//tools:install.bzl", "install", "install_files")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

package(
    default_visibility = ["//visibility:public"],
)

# Note that this is only a portion of Bullet.
cc_library(
    name = "bullet",
    srcs = glob([
        "src/BulletCollision/**/*.cpp",
        "src/LinearMath/**/*.cpp",
    ]),
    hdrs = glob([
        "src/BulletCollision/**/*.h",
        "src/LinearMath/**/*.h",
    ]) + ["src/btBulletCollisionCommon.h"],
    copts = ["-Wno-all"],
    defines = ["BT_USE_DOUBLE_PRECISION"],
    includes = ["src"],
)

py_binary(
    name = "create-cps",
    srcs = ["@//tools:bullet-create-cps.py"],
    main = "@//tools:bullet-create-cps.py",
    visibility = ["//visibility:private"],
)

genrule(
    name = "cps",
    srcs = ["CMakeLists.txt"],
    outs = ["bullet.cps"],
    cmd = "$(location :create-cps) \"$<\" > \"$@\"",
    tools = [":create-cps"],
    visibility = ["//visibility:private"],
)

genrule(
    name = "cmake_exports",
    srcs = ["bullet.cps"],
    outs = ["BulletConfig.cmake"],
    cmd = "$(location @pycps//:cps2cmake_executable) \"$<\" > \"$@\"",
    tools = ["@pycps//:cps2cmake_executable"],
    visibility = ["//visibility:private"],
)

install_files(
    name = "install_cmake",
    dest = "lib/cmake/bullet",
    files = [
        "BulletConfig.cmake",
    ],
)

install(
    name = "install",
    doc_dest = "share/doc/bullet",
    guess_hdrs = "PACKAGE",
    hdr_dest = "include/bullet",
    license_docs = glob(["LICENSE.txt"]),
    targets = ["bullet"],
    deps = ["install_cmake"],
)


pkg_tar(
    name = "license",
    extension = "tar.gz",
    files = ["LICENSE.txt"],
    mode = "0644",
    package_dir = "bullet",
)
