def _tool_wrapper_impl(ctx):
    f = ctx.actions.declare_file("run.sh")
    ctx.actions
    return [DefaultInfo(files = depset([ctx.file.src]))]

tool_wrapper = rule(
  attrs = {
    "src": attr.label(allow_single_file = True),
  }
)