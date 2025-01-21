load(":providers.bzl", "GnConfigSetInfo", "GnDepsInfo")

def _transition_impl(settings, attr):
    return {"//gn:current_toolchain": attr.toolchain}

# The transition itself needs to be defined in the package that generates //gn:current_toolchain.
_transition = transition(
    implementation = _transition_impl,
    inputs = [],
    outputs = ["//gn:current_toolchain"],
)

def _switch_toolchain_impl(ctx):
    actual = ctx.attr.actual

    # There's no API to get all providers, so we need to manually forward one-by-one.
    providers = []
    if DefaultInfo in actual:
        # Bazel requires that you actually create a new defaultinfo instance, you can't just copy it.
        providers.append(DefaultInfo(files = actual[DefaultInfo].files))
    if GnConfigSetInfo in actual:
        providers.append(actual[GnConfigSetInfo])
    if GnDepsInfo in actual:
        providers.append(actual[GnDepsInfo])
    return providers

switch_toolchain = rule(
    implementation = _switch_toolchain_impl,
    attrs = {
        "actual": attr.label(cfg = _transition),
        "toolchain": attr.label(mandatory = True),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist"
        ),
    },
)