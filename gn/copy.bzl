load(":providers.bzl", "GnConfigSetInfo", "GnDepsInfo", "GnToolchainInfo")
load(":tool.bzl", "parse_substitutions")
load("//gn/private:rule_helpers.bzl", "GENERAL_ATTRS", "collect_providers", "combine_deps", "configure_action", "disallow")
load("//gn/private:substitutions.bzl", "apply_substitutions")

def _copy_impl(ctx):
    disallow(ctx, ["configs"])
    providers = collect_providers(ctx)

    if len(ctx.attr.outputs) != 1:
        fail("outputs must have length 1")

    fmt = parse_substitutions(ctx.attr.outputs[0])


    out = []
    for src in ctx.files.sources:
        attrs = configure_action(ctx)
        attrs["source"] = src
        # f = ctx.actions.declare_file_at(apply_substitutions(fmt, attrs))
        f = ctx.actions.declare_file_at(apply_substitutions(fmt, attrs))
        out.append(f)

        # See https://github.com/bazelbuild/bazel-skylib/blob/main/rules/private/copy_file_private.bzl
        # This doesn't currently work on windows
        ctx.actions.run_shell(
            inputs = [src],
            outputs = [f],
            command = "ln -f \"$1\" \"$2\" || cp -f \"$1\" \"$2\"",
            arguments = [src.path, f.path],
            mnemonic = "CopyFile",
            progress_message = "Copying files",
            use_default_shell_env = True,
        )

    files = depset(out)

    return [
        DefaultInfo(files = files),
        combine_deps([providers.public_deps, GnDepsInfo(inputs = files)]),
        providers.public_configs,
    ]

copy = rule(
    implementation = _copy_impl,
    attrs = {
        "sources": attr.label_list(allow_files = True, mandatory = True),
        "outputs": attr.string_list(mandatory = True),
    } | GENERAL_ATTRS,
)
