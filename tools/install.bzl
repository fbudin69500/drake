# -*- python -*-

load("@drake//tools:pathutils.bzl", "output_path", "join_paths")

InstallInfo = provider()

#------------------------------------------------------------------------------
def _install_actions(ctx, file_labels, dests, strip_prefix = []):
    """Compute install actions for files.

    This takes a list of labels (targets or files) and computes the install
    actions for the files owned by each label.

    Args:
        file_labels (:obj:`list` of :obj:`Label`): labels to install.
        dests (:obj:`str` or :obj:`dict` of :obj:`str` to :obj:`str`):
            Install destination. If a :obj:`dict` may be given to supply a
            mapping of file extension to destination path.
        strip_prefix (:obj:`list` of :obj:`str`): List of prefixes to strip
            from the input path before prepending the destination.

    Returns:
        :obj:`list`: A list of install actions.
    """
    actions = []

    # Iterate over files. We expect a list of labels, which will have a 'files'
    # attribute that is a list of File artifacts. Thus this two-level loop.
    for f in file_labels:
        for a in f.files:
            if type(dests) == "dict":
                dest = dests.get(a.extension, dests[None])
            else:
                dest = dests
            p = output_path(ctx, a, strip_prefix)
            actions.append(struct(src = a, dst = join_paths(dest, p)))

    return actions

#------------------------------------------------------------------------------
# Compute install actions for a cc_library or cc_binary.
def _install_cc_actions(ctx, target):
    # Compute actions for target artifacts.
    dests = {
        "a": ctx.attr.archive_dest,
        "so": ctx.attr.library_dest,
        None: ctx.attr.runtime_dest,
    }
    actions = _install_actions(ctx, [target], dests)

    # Compute actions for guessed headers.
    if ctx.attr.guess_hdrs != "NONE":
        hdrs = []

        if ctx.attr.guess_hdrs == "EVERYTHING":
            hdrs = target.cc.transitive_headers

        elif ctx.attr.guess_hdrs == "WORKSPACE":
            hdrs = [h for h in target.cc.transitive_headers if
                    target.label.workspace_root == h.owner.workspace_root]

        elif ctx.attr.guess_hdrs == "PACKAGE":
            hdrs = [h for h in target.cc.transitive_headers if
                    target.label.workspace_root == h.owner.workspace_root and
                    target.label.package == h.owner.package]

        else:
            msg_fmt = "'install' given unknown 'guess_hdrs' value '%s'"
            fail(msg_fmt % ctx.attr.guess_hdrs, ctx.attr.guess_hdrs)

        actions += _install_actions(ctx, [struct(files=hdrs)],
                                    ctx.attr.hdr_dest,
                                    ctx.attr.hdr_strip_prefix)

    # Return computed actions.
    return actions

#------------------------------------------------------------------------------
# Compute install actions for a java_library or java_binary.
def _install_java_actions(ctx, target):
    # TODO(mwoehlke-kitware): Implement this. Probably it mainly needs the
    # logic to pick install destinations appropriately.
    return []

#------------------------------------------------------------------------------
# Generate install code for an install action.
def _install_code(action):
    return "install(%r, %r)" % (action.src.short_path, action.dst)

#END internal helpers
#==============================================================================
#BEGIN rules

#------------------------------------------------------------------------------
# Generate information to install "stuff". "Stuff" can be library or binary
# targets, headers, or documentation files.
def _install_impl(ctx):
    actions = []

    # Check for missing license files.
    if len(ctx.attr.targets) or len(ctx.attr.hdrs):
        if not len(ctx.attr.license_docs):
            fail("'install' missing 'license_docs'")

    # Collect install actions from dependencies.
    for d in ctx.attr.deps:
        actions += d.install_actions

    # Generate actions for docs and includes.
    actions += _install_actions(ctx, ctx.attr.license_docs, ctx.attr.doc_dest)
    actions += _install_actions(ctx, ctx.attr.docs, ctx.attr.doc_dest)
    actions += _install_actions(ctx, ctx.attr.hdrs, ctx.attr.hdr_dest,
                                ctx.attr.hdr_strip_prefix)

    for t in ctx.attr.targets:
        # TODO(jwnimmer-tri): Raise an error if a target has testonly=1.
        if hasattr(t, "cc"):
            actions += _install_cc_actions(ctx, t)
        elif hasattr(t, "java"):
            actions += _install_java_actions(ctx, t)

    # Generate code for install actions.
    script_actions = [_install_code(a) for a in actions]

    # Generate install script.
    # TODO(mwoehlke-kitware): Figure out a better way to generate this and run
    # it via Python than `#!/usr/bin/env python`?
    ctx.template_action(
        template = ctx.executable.install_script_template,
        output = ctx.outputs.executable,
        substitutions = {"<<actions>>": "\n    ".join(script_actions)})

    # Return actions.
    files = ctx.runfiles(files = [a.src for a in actions])
    return InstallInfo(install_actions = actions, runfiles = files)

install = rule(
    attrs = {
        "deps": attr.label_list(providers = ["install_actions"]),
        "docs": attr.label_list(allow_files = True),
        "doc_dest": attr.string(default = "share/doc"),
        "license_docs": attr.label_list(allow_files = True),
        "hdrs": attr.label_list(allow_files = True),
        "hdr_dest": attr.string(default = "include"),
        "hdr_strip_prefix": attr.string_list(),
        "guess_hdrs": attr.string(default = "NONE"),
        "targets": attr.label_list(),
        "archive_dest": attr.string(default = "lib"),
        "library_dest": attr.string(default = "lib"),
        "runtime_dest": attr.string(default = "bin"),
        "install_script_template": attr.label(
            allow_files = True,
            executable = True,
            cfg = "target",
            default = Label("//tools:install.py.in"),
        ),
    },
    executable = True,
    implementation = _install_impl,
)

"""Generate installation information for various artifacts.

This generates installation information for various artifacts, including
documentation and header files, and targets (e.g. ``cc_binary``). By default,
the path of any files is included in the install destination.
See :rule:`install_files` for details.

Note:
    By default, headers to be installed must be explicitly listed. This is to
    work around an issue where Bazel does not appear to provide any mechanism
    to obtain the public headers of a target at rule instantiation. The
    ``guess_hdrs`` parameter may be used to tell ``install`` to guess at what
    headers will be installed. Possible values are:

    * ``"NONE"``: Only install headers which are explicitly listed by ``hdrs``.
    * ``PACKAGE``:  For each target, install those headers which are used by
      the target and owned by a target in the same package.
    * ``WORKSPACE``: For each target, install those headers which are used by
      the target and owned by a target in the same workspace.
    * ``EVERYTHING``: Install all headers used by the target.

    The headers considered are *all* headers transitively used by the target.
    Any option other than ``NONE`` is also likely to install private headers.

Args:
    deps: List of other install rules that this rule should include.
    docs: List of documentation files to install.
    doc_dest: Destination for documentation files (default = "share/doc").
    license_docs: List of license files to install (uses doc_dest).
    guess_hdrs: See note.
    hdrs: List of header files to install.
    hdr_dest: Destination for header files (default = "include").
    hdr_strip_prefix: List of prefixes to remove from header paths.
    targets: List of targets to install.
    archive_dest: Destination for static library targets (default = "lib").
    library_dest: Destination for shared library targets (default = "lib").
    runtime_dest: Destination for executable targets (default = "bin").
"""

#------------------------------------------------------------------------------
# Generate information to install files to specified destination.
def _install_files_impl(ctx):
    # Get path components.
    dest = ctx.attr.dest
    strip_prefix = ctx.attr.strip_prefix

    # Generate actions.
    actions = _install_actions(ctx, ctx.attr.files, dest, strip_prefix)

    # Return computed actions.
    return InstallInfo(install_actions = actions)

install_files = rule(
    attrs = {
        "dest": attr.string(mandatory = True),
        "files": attr.label_list(allow_files = True),
        "strip_prefix": attr.string_list(),
    },
    implementation = _install_files_impl,
)

"""Generate installation information for files.

This generates installation information for a list of files. By default, any
path portion of the file as named is included in the install destination. For
example::

    install_files(
        dest = "docs",
        files = ["foo/bar.txt"],
        ...)

This will install ``bar.txt`` to the destination ``docs/foo``.

When this behavior is undesired, the ``strip_prefix`` parameter may be used to
specify a list of prefixes to be removed from input file paths before computing
the destination path. Stripping is not recursive; the first matching prefix
will be stripped. Prefixes support the single-glob (``*``) to match any single
path component, or the multi-glob (``**``) to match any number of path
components. Multi-glob matching is greedy. Globs may only be matched against
complete path components (e.g. ``a/*/`` is okay, but ``a*/`` is not treated as
a glob and will be matched literally). Due to Skylark limitations, at most one
``**`` may be matched.

Args:
    dest: Destination for files.
    files: List of files to install.
    strip_prefix: List of prefixes to remove from input paths.
"""

#END rules
#==============================================================================
#BEGIN macros

#------------------------------------------------------------------------------
def exports_create_cps_scripts(packages):
    """Export scripts that create CPS files to other packages.

    Args:
        packages (:obj:`list` of :obj:`str`): Bazel package names.
    """

    for package in packages:
        native.exports_files(
            ["{}-create-cps.py".format(package)],
            visibility = ["@{}//:__pkg__".format(package)],
        )

#------------------------------------------------------------------------------
def cmake_config(package, script, version_file, deps = []):
    """Create CMake package configuration and package version files via an
    intermediate CPS file.

    Args:
        package (:obj:`str`): CMake package name.
        script (:obj:`Label`): Script that creates the intermediate CPS file.
        version_file (:obj:`str`): File that the script will search to
            determine the version of the package.
    """
    native.py_binary(
        name = "create-cps",
        srcs = [script],
        main = script,
        visibility = ["//visibility:private"],
        deps = ["@drake//tools:cpsutils"],
    )

    cps_file_name = "{}.cps".format(package)

    native.genrule(
        name = "cps",
        srcs = [version_file] + deps,
        outs = [cps_file_name],
        cmd = "$(location :create-cps) $(SRCS) > \"$@\"",
        tools = [":create-cps"],
        visibility = ["//visibility:public"],
    )

    config_file_name = "{}Config.cmake".format(package)

    native.genrule(
        name = "cmake_exports",
        srcs = [cps_file_name],
        outs = [config_file_name],
        cmd = "$(location @pycps//:cps2cmake_executable) \"$<\" > \"$@\"",
        tools = ["@pycps//:cps2cmake_executable"],
        visibility = ["//visibility:private"],
    )

    config_version_file_name = "{}ConfigVersion.cmake".format(package)

    native.genrule(
        name = "cmake_package_version",
        srcs = [cps_file_name],
        outs = [config_version_file_name],
        cmd = "$(location @pycps//:cps2cmake_executable) --version-check \"$<\" > \"$@\"",
        tools = ["@pycps//:cps2cmake_executable"],
        visibility = ["//visibility:private"],
    )

#------------------------------------------------------------------------------
def install_cmake_config(package):
    """Generate installation information for CMake package configuration and
    package version files. The rule name is always ``:install_cmake_config``.

    Args:
        package (:obj:`str`): CMake package name.
    """
    cmake_config_dest = "lib/cmake/{}".format(package.lower())
    config_file_name = "{}Config.cmake".format(package)
    config_version_file_name = "{}ConfigVersion.cmake".format(package)

    install_files(
        name = "install_cmake_config",
        dest = cmake_config_dest,
        files = [
            config_file_name,
            config_version_file_name,
        ],
    )

#END macros
