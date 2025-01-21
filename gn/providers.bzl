GnCcInfo = provider(
    doc = "Information about a C++ target",
    fields = {
        "sources": "(depset[File])",
        "public": "(depset[File])",
        "modulemap_files": "(depset[File]) The modulemap files to depend on",
    },
)

GnToolInfo = provider(
    doc = "Information about a GN tool",
    fields = {
        "tool": "rules_toolchain's ToolInfo",
        "command": "([(string, sequence[string])]) A list of arguments. Each argument has the form (format_string, variable names)",
        "data": "([File]) The files needed to run the tool",
        "action": "ActionTypeInfo",
        "command_launcher": "string",
        "default_output_dir": "string",
        "default_output_extension": "string",
        "depfile": "string",
        "depsformat": "string",
        "description": "string",
        "exe_output_extension": "string",
        "rlib_output_extension": "string",
        "dylib_output_extension": "string",
        "cdylib_output_extension": "string",
        "rust_proc_macro_output_extension": "string",
        "lib_switch": "string",
        "lib_dir_switch": "string",
        "framework_switch": "string",
        "weak_framework_switch": "string",
        "framework_dir_switch": "string",
        "swiftmodule_switch": "string",
        "rust_swiftmodule_switch": "string",
        "outputs": "[(string, sequence[string])]",
        "partial_outputs": "[(string, sequence[string])]",
        "pool": "string",
        "link_output": "string",
        "depend_output": "string",
        "output_prefix": "string",
        "precompiled_header_type": "string",
        "restat": "bool",
        "rspfile": "string",
        "rspfile_content": "string",
        "runtime_outputs": "list[string]",
        "rust_sysroot": "string",
        "dynamic_link_switch": "string",
    },
)

GnToolchainInfo = provider(
  fields = {
    "tools": "dict[str, GnToolInfo]",
    "root_build_dir": "string",
    "root_out_dir": "string",
    "root_gen_dir": "string",
    "bazel_exec_dir": "string",
  }
)

GnConfigInfo = provider(
    doc = "Configuration from a GN config.",
    fields = {
        "asmflags": "List of strings",
        "cflags": "List of strings",
        "cflags_c": "List of strings",
        "cflags_cc": "List of strings",
        "cflags_objc": "List of strings",
        "cflags_objcc": "List of strings",
        "defines": "List of strings",
        "include_dirs": "List of strings/paths",
        "inputs": "List of labels/paths",
        "ldflags": "List of strings",
        "lib_dirs": "List of strings/paths",
        "libs": "List of strings",
        "precompiled_header": "String",
        "precompiled_source": "Label/path",
        "rustenv": "List of strings",
        "rustflags": "List of strings",
        "swiftflags": "List of strings",
    },
)

GnConfigSetInfo = provider(
    doc = "A set of configurations.",
    fields = {
        "configs": "A depset of GnConfigInfo",
    },
)

GnDepsInfo = provider(
  doc = "A set of dependencies.",
  fields = {
    "inputs": "A depset of File",
  }
)
