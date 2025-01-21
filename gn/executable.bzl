load("//gn/private:rule_helpers.bzl", "GENERAL_ATTRS")

def _impl(ctx):
    pass

executable = rule(
    implementation = _impl,
    attrs = {
        "sources": attr.label_list(allow_files = True),
        "deps": attr.label_list(allow_files = True),
        "public": attr.label_list(allow_files = True),
        "configs": attr.label_list(allow_files = True),
        "all_dependent_configs": attr.label_list(allow_files = True),
        "public_configs": attr.label_list(allow_files = True),
        "data": attr.label_list(allow_files = True),
        "public_deps": attr.label_list(allow_files = True),
        "data_deps": attr.label_list(allow_files = True),
        "assert_no_deps": attr.label_list(allow_files = True),
        "write_runtime_deps": attr.label_list(allow_files = True),
        "tools": attr.string_dict(),
        "command": attr.string(),
        "command_launcher": attr.string(),
        "default_output_extension": attr.string(),
        "depfile": attr.string(),
        "description": attr.string(),
        "runtime_outputs": attr.string_list(),
        "output_prefix": attr.string(),
        "default_output_dir": attr.string(),
        "restat": attr.bool(),
        "rspfile": attr.string(),
        "rspfile_content": attr.string(),
        "pool": attr.string(),
    } | GENERAL_ATTRS,
)
