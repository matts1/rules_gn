load("//gn:providers.bzl", "GnConfigSetInfo", "GnDepsInfo", "GnToolchainInfo")

def combine_deps(deps):
    if len(deps) == 1:
        return deps[0]
    return GnDepsInfo(
        inputs = depset(transitive = [d.inputs for d in deps]),
    )

def merge_depset(d, transitive):
    if transitive:
        return depset(transitive = transitive + [d])
    else:
        return d

def collect_providers(ctx):
    public = ctx.attr.public_deps + ctx.attr.public_configs
    private = ctx.attr.deps + ctx.attr.configs

    public_configs = depset(transitive = [c[GnConfigSetInfo].configs for c in public])
    private_configs = merge_depset(public_configs, [c[GnConfigSetInfo].configs for c in private])

    public_deps = combine_deps([d[GnDepsInfo] for d in public if GnDepsInfo in d])
    if private:
        private_deps = combine_deps([public_deps] + [d[GnDepsInfo] for d in private if GnDepsInfo in d])
    else:
        private_deps = public_deps

    return struct(
        public_configs = GnConfigSetInfo(configs = public_configs),
        private_configs = private_configs,
        public_deps = public_deps,
        private_deps = private_deps,
    )

def disallow(ctx, fields):
    for f in fields:
        if getattr(ctx.attr, f, None):
            fail("Attribute %s is not allowed, got %s in %s" % (f, getattr(ctx.attr, f), ctx.label))

def configure_action(ctx):
    return {
        "toolchain": ctx.attr._toolchain[GnToolchainInfo],
        "ctx": ctx,
    }

GENERAL_ATTRS = {
    "configs": attr.label_list(providers = [GnConfigSetInfo]),
    "deps": attr.label_list(providers = [GnDepsInfo, GnConfigSetInfo]),
    "public": attr.label_list(allow_files = True),
    "public_configs": attr.label_list(providers = [GnConfigSetInfo]),
    "public_deps": attr.label_list(providers = [GnDepsInfo, GnConfigSetInfo]),
    "_toolchain": attr.label(providers = [GnToolchainInfo], default = "//gn:current_toolchain")
}
