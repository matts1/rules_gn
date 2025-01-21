def path_relative_to_build_dir_to_label(path):
  """Converts a GN path relative to the root directory to a bazel label."""
  if path.startswith("../../"):
    return "@@//:%s" % path[6:]
  else:
    print("Not implemented: path_relative_to_build_dir_to_label(%s)" % path)
    # A dummy path
    return "@@//:MODULE.bazel"
  
def gn_source_path_to_root_path(path):
  # Path is relative to the output directory
  if path.startswith("//external"):
    return path.split("/", 4)[-1]
  # Path is relative to the root source directory
  elif path.startswith("//"):
    return "../../" + path[2:]
  else:
    # Path is relative to the current directory.
    fail("NEED TOOLCHAIN FOR %s" % path)