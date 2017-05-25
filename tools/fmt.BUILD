# -*- python -*-

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")
load("@//tools:install.bzl", "install", "install_files")

package(
    default_visibility = ["//visibility:public"],
)

cc_library(
    name = "fmt",
    srcs = glob(["fmt/*.cc"]),
    hdrs = glob(["fmt/*.h"]),
    includes = ["."],
)

py_binary(
    name = "create-cps",
    srcs = ["@//tools:fmt-create-cps.py"],
    main = "@//tools:fmt-create-cps.py",
    visibility = ["//visibility:private"],
)

genrule(
    name = "cps",
    srcs = ["CMakeLists.txt"],
    outs = ["fmt.cps"],
    cmd = "$(location :create-cps) \"$<\" > \"$@\"",
    tools = [":create-cps"],
    visibility = ["//visibility:private"],
)

genrule(
    name = "cmake_exports",
    srcs = ["fmt.cps"],
    outs = ["fmtConfig.cmake"],
    cmd = "$(location @pycps//:cps2cmake_executable) \"$<\" > \"$@\"",
    tools = ["@pycps//:cps2cmake_executable"],
    visibility = ["//visibility:private"],
)

genrule(
    name = "cmake_package_version",
    srcs = ["fmt.cps"],
    outs = ["fmtConfigVersion.cmake"],
    cmd = "$(location @pycps//:cps2cmake_executable) --version-check \"$<\" > \"$@\"",
    tools = ["@pycps//:cps2cmake_executable"],
    visibility = ["//visibility:private"],
)

install_files(
    name = "install_cmake",
    dest = "lib/cmake/fmt",
    files = [
        "fmtConfig.cmake",
        "fmtConfigVersion.cmake",
    ],
)

install(
    name = "install",
    doc_dest = "share/doc/fmt",
    guess_hdrs = "PACKAGE",
    hdr_dest = "include/fmt",
    license_docs = glob(["LICENSE.rst"]),
    targets = ["fmt"],
    deps = ["install_cmake"],
)


pkg_tar(
    name = "license",
    extension = "tar.gz",
    files = ["LICENSE.rst"],
    mode = "0644",
    package_dir = "fmt",
)
