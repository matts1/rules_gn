load(":providers.bzl", "GnConfigInfo", "GnConfigSetInfo", "GnDepsInfo")
load("//gn/private:rule_helpers.bzl", "GENERAL_ATTRS", "collect_providers", "combine_deps", "disallow")
load("//gn/private:converters.bzl", "gn_source_path_to_root_path")

def _impl(ctx):
    disallow(ctx, ["public", "deps", "public_deps"])

    providers = collect_providers(ctx)

    out = []
    if ctx.files.inputs or providers.private_deps:
        deps = providers.private_deps
        if ctx.files.inputs:
            deps = GnDepsInfo(
                inputs = depset(direct = ctx.files.inputs),
            )
            if providers.private_deps:
                deps = combine_deps([deps, providers.private_deps])
        out.append(deps)

    include_dirs = []
    for d in ctx.attr.include_dirs:
        include_dirs.append(gn_source_path_to_root_path(d))

    # Convert them to tuples so they become hashable.
    # This way we can put them in a depset.
    direct = GnConfigInfo(
        asmflags = tuple(ctx.attr.asmflags),
        cflags = tuple(ctx.attr.cflags),
        cflags_c = tuple(ctx.attr.cflags_c),
        cflags_cc = tuple(ctx.attr.cflags_cc),
        cflags_objc = tuple(ctx.attr.cflags_objc),
        cflags_objcc = tuple(ctx.attr.cflags_objcc),
        defines = tuple(ctx.attr.defines),
        include_dirs = tuple(include_dirs),
        ldflags = tuple(ctx.attr.ldflags),
        lib_dirs = tuple(ctx.files.lib_dirs),
        libs = tuple(ctx.attr.libs),
        precompiled_header = ctx.attr.precompiled_header,
        precompiled_source = ctx.file.precompiled_source,
        rustenv = tuple(ctx.attr.rustenv),
        rustflags = tuple(ctx.attr.rustflags),
        swiftflags = tuple(ctx.attr.swiftflags),
    )

    return [
        GnConfigSetInfo(configs = depset(
            direct = [direct],
            # We use private_configs because we explicitly want to include non-public configs.
            transitive = [
                providers.private_configs,
            ],
        )),
    ] + out

config = rule(
    implementation = _impl,
    attrs = {
        "asmflags": attr.string_list(),
        "cflags": attr.string_list(),
        "cflags_c": attr.string_list(),
        "cflags_cc": attr.string_list(),
        "cflags_objc": attr.string_list(),
        "cflags_objcc": attr.string_list(),
        "configs": attr.label_list(providers = [GnConfigSetInfo]),
        "defines": attr.string_list(),
        "include_dirs": attr.string_list(),
        "inputs": attr.label_list(allow_files = True),
        "ldflags": attr.string_list(),
        "lib_dirs": attr.label_list(allow_files = True),
        "libs": attr.string_list(),
        "precompiled_header": attr.string(),
        "precompiled_source": attr.label(allow_single_file = True),
        "rustenv": attr.string_list(),
        "rustflags": attr.string_list(),
        "swiftflags": attr.string_list(),
    } |  GENERAL_ATTRS,
)
