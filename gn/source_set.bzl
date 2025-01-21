load("//gn/private:rule_helpers.bzl", "GENERAL_ATTRS", "collect_providers", "configure_action")
load("//gn/private:substitutions.bzl", "apply_substitutions", "write_command")
load("//gn/private:file.bzl", "select_tool")

def _source_set_impl(ctx):
    providers = collect_providers(ctx)
    attrs = configure_action(ctx)
    libraries = []
    for source in ctx.files.sources:
        attrs["source"] = source
        attrs["configs"] = providers.private_configs.to_list()
        attrs["deps"] = providers.private_deps
        tool = select_tool(source)
        if tool == None:
            continue
        tool = attrs["toolchain"].tools[tool]
        attrs["tool"] = tool
        outputs = [
            ctx.actions.declare_file_at(apply_substitutions(output, attrs))
            for output in tool.outputs
        ]

        # Assume this is the primary output
        output = outputs[0]
        libraries.append(output)
        attrs["output"] = output
        if tool.depfile:
            depfile = ctx.actions.declare_file_at(apply_substitutions(tool.depfile, attrs))
            outputs.append(depfile)

        args = ctx.actions.args()
        write_command(args, tool.command, attrs)
        ctx.actions.run(
            outputs = outputs,
            inputs = depset(
                direct = [source],
                transitive = [providers.private_deps.inputs, tool.tool.files_to_run],
            ),
            progress_message = apply_substitutions(tool.description, attrs) if tool.description else None,
            executable = tool.tool.exe,
            arguments = [args],
        )

    return [
        DefaultInfo(files = depset(libraries)),
        providers.public_configs,
        providers.public_deps,
    ]

source_set = rule(
    implementation = _source_set_impl,
    attrs = {
        "sources": attr.label_list(allow_files = True),
        "public": attr.label_list(allow_files = True),
    } | GENERAL_ATTRS,
)
