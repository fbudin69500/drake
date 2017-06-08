# -*- python -*-

load("@drake//tools:pathutils.bzl", "output_path")

# The CLANG_FLAGS will be enabled for all C++ rules in the project when
# building with clang.
CLANG_FLAGS = [
    "-Werror=all",
    "-Werror=inconsistent-missing-override",
    "-Werror=sign-compare",
    "-Werror=non-virtual-dtor",
    "-Werror=return-stack-address",
]

# The GCC_FLAGS will be enabled for all C++ rules in the project when
# building with gcc.
GCC_FLAGS = [
    "-Werror=all",
    "-Werror=extra",
    "-Werror=return-local-addr",
    "-Werror=non-virtual-dtor",
    "-Wno-missing-field-initializers",
]

# The GCC_CC_TEST_FLAGS will be enabled for all cc_test rules in the project
# when building with gcc.
GCC_CC_TEST_FLAGS = [
    "-Wno-unused-parameter",
]

def _platform_copts(rule_copts, cc_test=0):
    """Returns both the rule_copts, and platform-specific copts.

    When cc_test=1, the GCC_CC_TEST_FLAGS will be added.  It should only be set
    to 1 from cc_test rules or rules that are boil down to cc_test rules.
    """
    extra_gcc_flags = []
    if cc_test:
        extra_gcc_flags = GCC_CC_TEST_FLAGS
    return select({
        "//tools:gcc4.9-linux": GCC_FLAGS + extra_gcc_flags + rule_copts,
        "//tools:gcc5-linux": GCC_FLAGS + extra_gcc_flags + rule_copts,
        "//tools:clang3.9-linux": CLANG_FLAGS + rule_copts,
        "//tools:apple": CLANG_FLAGS + rule_copts,
        "//conditions:default": rule_copts,
    })

def _dsym_command(name):
    """Returns the command to produce .dSYM on OS X, or a no-op on Linux."""
    return select({
        "//tools:apple_debug":
            "dsymutil -f $(location :" + name + ") -o $@ 2> /dev/null",
        "//conditions:default": "touch $@",
    })

def drake_cc_library(
        name,
        hdrs=None,
        srcs=None,
        deps=None,
        copts=[],
        linkstatic=1,
        **kwargs):
    """Creates a rule to declare a C++ library.

    By default, we produce only static libraries, to reduce compilation time
    on all platforms, and to avoid mysterious dyld errors on OS X. This default
    could be revisited if binary size becomes a concern.
    """
    native.cc_library(
        name=name,
        hdrs=hdrs,
        srcs=srcs,
        deps=deps,
        copts=_platform_copts(copts),
        linkstatic=linkstatic,
        **kwargs)

def drake_cc_binary(
        name,
        hdrs=None,
        srcs=None,
        deps=None,
        copts=[],
        linkstatic=1,
        testonly=0,
        add_test_rule=0,
        test_rule_args=[],
        test_rule_size=None,
        **kwargs):
    """Creates a rule to declare a C++ binary.

    By default, we prefer to link static libraries whenever they are available.
    This default could be revisited if binary size becomes a concern.

    If you wish to create a smoke-test demonstrating that your binary runs
    without crashing, supply add_test_rule=1. Note that if you wish to do
    this, you should consider suppressing that urge, and instead writing real
    tests. The smoke-test will be named <name>_test. You may override cc_test
    defaults using test_rule_args=["-f", "--bar=42"] or test_rule_size="baz".
    """
    native.cc_binary(
        name=name,
        hdrs=hdrs,
        srcs=srcs,
        deps=deps,
        copts=_platform_copts(copts),
        testonly=testonly,
        linkstatic=linkstatic,
        **kwargs)

    # Also generate the OS X debug symbol file for this binary.
    native.genrule(
        name=name + "_dsym",
        srcs=[":" + name],
        outs=[name + ".dSYM"],
        output_to_bindir=1,
        testonly=testonly,
        tags=["dsym"],
        visibility=["//visibility:private"],
        cmd=_dsym_command(name),
    )

    if add_test_rule:
        drake_cc_test(
            name=name + "_test",
            hdrs=hdrs,
            srcs=srcs,
            deps=deps,
            copts=copts,
            size=test_rule_size,
            testonly=testonly,
            linkstatic=linkstatic,
            args=test_rule_args,
            **kwargs)

def drake_cc_test(
        name,
        size=None,
        srcs=None,
        copts=[],
        disable_in_compilation_mode_dbg=False,
        **kwargs):
    """Creates a rule to declare a C++ unit test.  Note that for almost all
    cases, drake_cc_googletest should be used, instead of this rule.

    By default, sets size="small" because that indicates a unit test.
    By default, sets name="test/${name}.cc" per Drake's filename convention.

    If disable_in_compilation_mode_dbg is True, the srcs will be suppressed
    in debug-mode builds, so the test will trivially pass. This option should
    be used only rarely, and the reason should always be documented.
    """
    if size == None:
        size = "small"
    if srcs == None:
        srcs = ["test/%s.cc" % name]
    if disable_in_compilation_mode_dbg:
        # Remove the test declarations from the test in debug mode.
        # TODO(david-german-tri): Actually suppress the test rule.
        srcs = select({"//tools:debug" : [], "//conditions:default" : srcs})
    native.cc_test(
        name=name,
        size=size,
        srcs=srcs,
        copts=_platform_copts(copts, cc_test=1),
        **kwargs)

    # Also generate the OS X debug symbol file for this test.
    native.genrule(
        name=name + "_dsym",
        srcs=[":" + name],
        outs=[name + ".dSYM"],
        output_to_bindir=1,
        testonly=1,
        tags=["dsym"],
        visibility=["//visibility:private"],
        cmd=_dsym_command(name),
    )

def drake_cc_googletest(
        name,
        deps=None,
        use_default_main=True,
        **kwargs):
    """Creates a rule to declare a C++ unit test using googletest.  Always adds
    a deps= entry for googletest main (@gtest//:main).

    By default, sets size="small" because that indicates a unit test.
    By default, sets name="test/${name}.cc" per Drake's filename convention.
    By default, sets use_default_main=True to use GTest's main, via
    @gtest//:main. Otherwise, it will depend on @gtest//:without_main.

    If disable_in_compilation_mode_dbg is True, the srcs will be suppressed
    in debug-mode builds, so the test will trivially pass. This option should
    be used only rarely, and the reason should always be documented.
    """
    if deps == None:
        deps = []
    if use_default_main:
        deps.append("@gtest//:main")
    else:
        deps.append("@gtest//:without_main")
    drake_cc_test(
        name=name,
        deps=deps,
        **kwargs)

#------------------------------------------------------------------------------
# Generate a file with specified content
def _generate_file_impl(ctx):
    ctx.file_action(output=ctx.outputs.out, content=ctx.attr.content)

drake_generate_file = rule(
    attrs = {
        "content": attr.string(),
        "out": attr.output(mandatory = True),
    },
    output_to_genfiles = True,
    implementation = _generate_file_impl,
)

"""Generate a file with specified content.

This creates a rule to generate a file with specified content (which is either
static or has been previously computed).

Args:
    content (:obj:`str`): Desired content of the generated file.
"""

#------------------------------------------------------------------------------
# Generate a header that includes a set of other headers
def _generate_include_header_impl(ctx):
    # Collect list of headers
    hdrs = []
    for h in ctx.attr.hdrs:
        for f in h.files:
            hdrs.append(output_path(ctx, f, ctx.attr.strip_prefix))

    # Generate include header
    content = "\n".join(["#include <%s>" % h for h in hdrs])
    content = ctx.attr.prologue + content + "\n"
    ctx.file_action(output=ctx.outputs.out, content=content)

drake_generate_include_header = rule(
    attrs = {
        "hdrs": attr.label_list(allow_files = True),
        "prologue": attr.string(default = ""),
        "strip_prefix": attr.string_list(default = ["**/include/"]),
        "out": attr.output(mandatory = True),
    },
    output_to_genfiles = True,
    implementation = _generate_include_header_impl,
)

"""Generate a header that includes a set of other headers.

This creates a rule to generate a header that includes a list of other headers.
The generated file will be of the form::

    #include <hdr>
    #include <hdr>

Args:
    hdrs (:obj:`str`): List of files or file labels of headers that the
        generated header will include.
    prologue (:obj:`str`): Additional code to write before the ``#include``
        directives.
    strip_prefix (:obj:`list` of :obj:`str`): List of prefixes to strip from
        the header names when forming the ``#include`` directives.
"""
