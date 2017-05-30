# -*- python -*-

load("@//tools:install.bzl", "install", "install_files")
load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

package(
    default_visibility = ["//visibility:public"],
)


cc_library(
    name = "tinyobjloader",
    srcs = [
        "tiny_obj_loader.cc",
    ],
    hdrs = [
        "tiny_obj_loader.h",
    ],
    includes = ["."],
    linkstatic = 1,
    visibility = ["//visibility:public"],
)

py_binary(
    name = "create-cps",
    srcs = ["@//tools:tinyobjloader-create-cps.py"],
    main = "@//tools:tinyobjloader-create-cps.py",
    visibility = ["//visibility:private"],
)

genrule(
    name = "cps",
    srcs = ["CMakeLists.txt"],
    outs = ["tinyobjloader.cps"],
    cmd = "$(location :create-cps) \"$<\" > \"$@\"",
    tools = [":create-cps"],
    visibility = ["//visibility:private"],
)

genrule(
    name = "cmake_exports",
    srcs = ["tinyobjloader.cps"],
    outs = ["tinyobjloader-config.cmake"],
    cmd = "$(location @pycps//:cps2cmake_executable) \"$<\" > \"$@\"",
    tools = ["@pycps//:cps2cmake_executable"],
    visibility = ["//visibility:private"],
)

genrule(
    name = "cmake_package_version",
    srcs = ["tinyobjloader.cps"],
    outs = ["tinyobjloader-config-version.cmake"],
    cmd = "$(location @pycps//:cps2cmake_executable) --version-check \"$<\" > \"$@\"",
    tools = ["@pycps//:cps2cmake_executable"],
    visibility = ["//visibility:private"],
)

install_files(
    name = "install_cmake",
    dest = "lib/cmake/tinyobjloader",
    files = [
        "tinyobjloader-config.cmake",
        "tinyobjloader-config-version.cmake",
    ],
)

install(
    name = "install",
    doc_dest = "share/doc/tinyobjloader",
    guess_hdrs = "PACKAGE",
    hdr_dest = "include/tinyobjloader",
    license_docs = glob(["LICENSE"]),
    targets = ["tinyobjloader"],
    deps = ["install_cmake"],
)

pkg_tar(
    name = "license",
    extension = "tar.gz",
    files = ["LICENSE"],
    mode = "0644",
    package_dir = "tinyobjloader",
    visibility = ["//visibility:public"],
)
