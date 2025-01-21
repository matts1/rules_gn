load(":providers.bzl", "GnConfigSetInfo", "GnDepsInfo")
load("//gn/private:rule_helpers.bzl", "GENERAL_ATTRS", "collect_providers", "combine_deps")

def _group_impl(ctx):
    providers = collect_providers(ctx)

    if ctx.files.data:
        deps = combine_deps([providers.private_deps] + [GnDepsInfo(inputs = depset(direct = ctx.files.data))])
    else:
        deps = providers.private_deps

    return [
        DefaultInfo(files = depset([
        ])),
        GnConfigSetInfo(configs = providers.private_configs),
        deps,
    ]

group = rule(
    implementation = _group_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
    } | GENERAL_ATTRS,
)
