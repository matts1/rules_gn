# This is a copy of @bazel-skylib's expand_template, with https://github.com/bazelbuild/bazel-skylib/pull/618 already applied.

def _expand_template_impl(ctx):
    ctx.actions.expand_template(
        template = ctx.file.template,
        output = ctx.outputs.out,
        substitutions = ctx.attr.substitutions,
        is_executable = ctx.attr.is_executable,
    )
    if ctx.attr.is_executable:
      return [DefaultInfo(executable = ctx.outputs.out)]

expand_template = rule(
    implementation = _expand_template_impl,
    doc = """Template expansion

This performs a simple search over the template file for the keys in
substitutions, and replaces them with the corresponding values.

There is no special syntax for the keys. To avoid conflicts, you would need to
explicitly add delimiters to the key strings, for example "{KEY}" or "@KEY@".""",
    attrs = {
        "template": attr.label(
            mandatory = True,
            allow_single_file = True,
            doc = "The template file to expand.",
        ),
        "substitutions": attr.string_dict(
            mandatory = True,
            doc = "A dictionary mapping strings to their substitutions.",
        ),
        "out": attr.output(
            mandatory = True,
            doc = "The destination of the expanded file.",
        ),
        "is_executable": attr.bool(
            default = False,
            doc = "Whether the expanded file is executable",
        ),
    },
)