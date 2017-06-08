# -*- python -*-
load("@drake//tools:cmake_configure_file.bzl", "cmake_configure_file")
load("@drake//tools:install.bzl", "cmake_config", "install", "install_cmake_config")
load("@drake//tools:drake.bzl", "generate_include_header")

package(default_visibility = ["//visibility:public"])

# Generates config.hh based on the version numbers in CMake code.
cmake_configure_file(
    name = "config",
    src = "cmake/config.hh.in",
    out = "include/ignition/rndf/config.hh",
    cmakelists = ["CMakeLists.txt"],
    defines = [
        # It would be nice to get this information directly from CMakeLists.txt,
        # but it ends up being too hard. We'd have to extend the cmake_configure_file
        # functionality to create variables from "project" command as well as manipulate
        # strings, and I'm not sure it is worth it.  We just hard code some values that
        # should not change.
        "PROJECT_NAME=ignition-rndf",
        "PROJECT_NAME_LOWER=ignition-rndf",
    ],
    visibility = ["//visibility:private"],
)

public_headers = [
    "include/ignition/rndf/Checkpoint.hh",
    "include/ignition/rndf/Exit.hh",
    "include/ignition/rndf/Helpers.hh",
    "include/ignition/rndf/Lane.hh",
    "include/ignition/rndf/ParkingSpot.hh",
    "include/ignition/rndf/ParserUtils.hh",
    "include/ignition/rndf/Perimeter.hh",
    "include/ignition/rndf/RNDF.hh",
    "include/ignition/rndf/RNDFNode.hh",
    "include/ignition/rndf/Segment.hh",
    "include/ignition/rndf/UniqueId.hh",
    "include/ignition/rndf/Waypoint.hh",
    "include/ignition/rndf/Zone.hh",
]

# Generates rndf.hh, which consists of #include statements for all of the
# public headers in the library.  The first line is
# '#include <ignition/rndf/config.hh>' followed by one line like
# '#include <ignition/rndf/Checkpoint.hh>' for each non-generated header.
generate_include_header(
    name = "rndfhh_genrule",
    srcs = [":config"] + public_headers,
    outs = ["include/ignition/rndf.hh"],
)

cc_library(
    name = "ignition_rndf",
    srcs = glob(
        ["src/*.cc"],
        exclude = ["src/*_TEST.cc"],
    ),
    hdrs = glob([
        "include/**/*.hh",
    ]),
    includes = ["include"],
    visibility = ["//visibility:public"],
    deps = [
        "@ignition_math",
    ],
)

cmake_config(
    package = "ignition_rndf",
    script = "@drake//tools:ignition_rndf-create-cps.py",
    version_file = "CMakeLists.txt",
    deps = ["@ignition_math//:cps"],
)

install_cmake_config(package = "ignition_rndf")  # Creates rule :install_cmake_config.

install(
    name = "install",
    hdrs = public_headers + [
        ":config",
        ":rndfhh_genrule",
    ],
    doc_dest = "share/doc/ignition_rndf",
    hdr_dest = "include",
    hdr_strip_prefix = ["include"],
    license_docs = ["COPYING"],
    targets = [":ignition_rndf"],
    deps = [":install_cmake_config"],
)
