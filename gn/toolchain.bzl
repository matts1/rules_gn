load(":providers.bzl", "GnToolInfo", "GnToolchainInfo")


def toolchain(*, name, **kwargs):
    _toolchain(name = name, **kwargs)

    # Define a config setting to check if this is our current toolchain.
    # Required for `select()` expressions
    native.config_setting(
        name = name + "_current",
        flag_values = {
            "//gn:current_toolchain": ":" + name,
        },
    )

def _toolchain_impl(ctx):
    if ctx.attr.propagates_configs:
        fail("Unsupported propagates configs in toolchain")
    if ctx.attr.deps:
        fail("Unsupported deps in toolchain")

    # Strip off both start and end
    # //out/debug/ => out/debug
    root_build_dir = ctx.attr.root_build_dir.rstrip("/")
    root_out_dir = root_build_dir
    if not ctx.attr.is_default:
        root_out_dir += "/" + ctx.attr.name
    root_gen_dir = root_out_dir + "/gen"

    tools = [tool[GnToolInfo] for tool in ctx.attr.tools]
    return [GnToolchainInfo(
        tools = {
            tool.action.label.name: tool
            for tool in tools
        },
        root_build_dir = root_build_dir,
        root_out_dir = root_out_dir,
        root_gen_dir = root_gen_dir,
        bazel_exec_dir = root_build_dir.lstrip("/")
    )]

_toolchain = rule(
    implementation = _toolchain_impl,
    provides = [GnToolchainInfo],
    attrs = {
        "propagates_configs": attr.bool(default = False),
        "deps": attr.label_list(),
        "tools": attr.label_list(providers = [GnToolInfo]),
        "is_default": attr.bool(default = False),
        "root_build_dir": attr.string(mandatory = True),
    },
)
