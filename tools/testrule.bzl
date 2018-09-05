# -*- python -*-

#def _impl(ctx):
#    output = ctx.outputs.out
#    ctx.actions.run_shell(
#        command = "ls",
#        outputs= [output],
#        progress_message = "Printing location",
#    )

#my_rule = rule(
#    attrs = {
#    },
#    executable = False,
#    implementation = _impl,
#    outputs = {"out": "%{name}.size"},
#)


def _impl(ctx):
    output = ctx.outputs.out

    file_labels = ctx.attr.deps
    l_files = depset()
    l = []
    includes = []
    for f in file_labels:
        if hasattr(f, "cc"):
            # "quote_include_directories", "system_include_directories", "transitive_headers"
            l_files += f.cc.transitive_headers
            includes += f.cc.include_directories

    ctx.actions.run(
        outputs= [output],
        inputs = l_files.to_list(),
        arguments = [output.path] + includes,
        progress_message = "Printing location",
        executable = ctx.executable.script,
    )

my_rule = rule(
    attrs = {
        "deps": attr.label_list(),
        "script": attr.label(
            executable = True,
            cfg = "host",
            allow_files = True,
            default = Label("//:execute"),
        ),
    },
    executable = False,
    implementation = _impl,
    outputs = {"out": "%{name}.size"},
)
