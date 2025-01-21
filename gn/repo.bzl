def _gn_to_bazel_impl(repo_ctx):
    gn = repo_ctx.getenv("GN_PATH", "/tmp/gn-release/gn")

    # This will never happen because the previous line has a default. We'll remove the default later.
    if gn == None:
        gn = repo_ctx.which("gn")
    if gn == None:
        fail("GN not found")
    repo_ctx.watch(gn)

    out_dir = str(repo_ctx.path("."))

    # Remove the symlink bazel-out, as the fact that it's a symlink messes with GN gen's relative paths
    repo_ctx.execute(["rm", "-f", str(repo_ctx.workspace_root.get_child("bazel-out"))])
    cmd = [gn, "gen", "bazel-out/%s" % repo_ctx.name, "--bazel=%s" % out_dir]
    status = repo_ctx.execute(
        cmd,
        working_directory = str(repo_ctx.workspace_root),
        quiet = False,
    )
    if status.return_code != 0:
        fail("'%s' failed with error code %d: %s" % (" ".join(cmd), status.return_code, status.stderr))

    repo_ctx.symlink(
        repo_ctx.attr._repo_dir,
        repo_ctx.path("gn"),
    )
    repo_ctx.execute(["rm", "-rf", str(repo_ctx.workspace_root.get_child("bazel-out"))])

    # Regenerate if any files read by GN have changed.
    build_gn_files = repo_ctx.read(repo_ctx.path("DEPS.txt")).split("\n")
    for f in build_gn_files:
        repo_ctx.watch(repo_ctx.workspace_root.get_child(f))

gn_to_bazel = repository_rule(
    implementation = _gn_to_bazel_impl,
    attrs = {
        "_repo_dir": attr.label(allow_files = True, default = "@rules_gn//:gn"),
    },
)
