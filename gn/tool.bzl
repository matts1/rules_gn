load("@rules_toolchains//toolchains:toolchain_info.bzl", "ActionTypeInfo", "ToolInfo")
load("//gn/private:converters.bzl", "path_relative_to_build_dir_to_label")
load(":providers.bzl", "GnToolInfo")

KIND_LITERAL = 1
KIND_VARIABLE = 2
KIND_SUBSTITUTION = 3

# Bazel doesn't support multiple substitutions in a single argument, so we need to do this manually.
KIND_MULTI_SUBSTITUTION = 4

def shlex_split(command):
    args = []
    in_quote = False
    start = 0
    for i in range(len(command)):
        c = command[i]
        if c == '"':
            in_quote = not in_quote
        elif c == " " and not in_quote:
            args.append(command[start:i].replace('"', ""))
            start = i + 1
    if len(command) > start:
        args.append(command[start:].replace('"', ""))
    return [arg for arg in args if arg]

def parse_substitutions(arg):
    """Parses a string which may contain GN substitutions.

    Returns a list of tuples of (string, is_variable)

    example:
    parse_substitutions("-o={{output}}") == ("-o=%s", ["output"])
    """
    if not arg:
        return None

    # States 0-3 correspond to where we are in a substitution
    # 0 -> in literal
    # 1 -> saw first "{" of substitution
    # 2 -> saw second "{" of substitution
    # 3 -> saw first "}" of substitution
    state = 0
    start = 0
    out = []
    vars = []
    for i in range(len(arg)):
        c = arg[i]
        if state == 0:
            if c == "{":
                state = 1
        elif state == 1:
            if c == "{":
                state = 2
                out.append(arg[start:i - 1])
                start = i + 1
            else:
                state = 0
        elif state == 2:
            if c == "}":
                state = 3
        elif state == 3:
            if c == "}":
                state = 0
                out.append("%s")
                vars.append(arg[start:i - 1])
                start = i + 1
            else:
                state = 2
    out.append(arg[start:])

    if state != 0:
        fail("Unterminated substitution in %s" % arg)
    return "".join(out), tuple(vars)

def tool(*, command, **kwargs):
    # GN executes these in a shell, but bazel handles proper arg parsing for you.
    args = shlex_split(command)

    # rm foo && ... => ..., since bazel doesn't need to remove files
    if args[0] == "rm":
        args = args[args.index("&&") + 1:]

    # The executable needs to be available
    if args[0] == "python3":
        data = [args[1]]
    else:
        data = [args[0]]

    _tool(
        args = args,
        data = [
            path_relative_to_build_dir_to_label(d)
            for d in data
            # If there's no / in the path, it's probably supposed to resolve using $PATH
            if "/" in d
        ],
        **kwargs
    )

def _tool_impl(ctx):
    action_type_info = ctx.attr.action[ActionTypeInfo]

    tool_info = ToolInfo(
        label = ctx.label,
        exe = ctx.executable._wrapper,
        files_to_run = depset(ctx.files.data),
    )

    # We pre-parse substitutions so we don't have to parse them in each action, just once globally.
    tool_info = GnToolInfo(
        tool = tool_info,
        command = [parse_substitutions(arg) for arg in ctx.attr.args],
        action = action_type_info,
        command_launcher = ctx.attr.command_launcher,
        default_output_dir = parse_substitutions(ctx.attr.default_output_dir),
        default_output_extension = ctx.attr.default_output_extension,
        depfile = parse_substitutions(ctx.attr.depfile),
        depsformat = ctx.attr.depsformat,
        description = parse_substitutions(ctx.attr.description),
        exe_output_extension = ctx.attr.exe_output_extension,
        rlib_output_extension = ctx.attr.rlib_output_extension,
        dylib_output_extension = ctx.attr.dylib_output_extension,
        cdylib_output_extension = ctx.attr.cdylib_output_extension,
        rust_proc_macro_output_extension = ctx.attr.rust_proc_macro_output_extension,
        lib_switch = ctx.attr.lib_switch,
        lib_dir_switch = ctx.attr.lib_dir_switch,
        framework_switch = ctx.attr.framework_switch,
        weak_framework_switch = ctx.attr.weak_framework_switch,
        framework_dir_switch = ctx.attr.framework_dir_switch,
        swiftmodule_switch = ctx.attr.swiftmodule_switch,
        rust_swiftmodule_switch = ctx.attr.rust_swiftmodule_switch,
        outputs = [parse_substitutions(arg) for arg in ctx.attr.outputs],
        partial_outputs = [parse_substitutions(arg) for arg in ctx.attr.partial_outputs],
        pool = ctx.attr.pool,
        link_output = parse_substitutions(ctx.attr.link_output),
        depend_output = parse_substitutions(ctx.attr.depend_output),
        output_prefix = ctx.attr.output_prefix,
        precompiled_header_type = ctx.attr.precompiled_header_type,
        rspfile = parse_substitutions(ctx.attr.rspfile),
        rspfile_content = parse_substitutions(ctx.attr.rspfile_content),
        runtime_outputs = [parse_substitutions(arg) for arg in ctx.attr.runtime_outputs],
        rust_sysroot = ctx.attr.rust_sysroot,
        dynamic_link_switch = ctx.attr.dynamic_link_switch,
    )

    return [
        tool_info,
    ]

_tool = rule(
    implementation = _tool_impl,
    attrs = {
        "args": attr.string_list(mandatory = True),
        "action": attr.label(mandatory = True, providers = [ActionTypeInfo]),
        "data": attr.label_list(allow_files = True),
        "command_launcher": attr.string(),
        "default_output_dir": attr.string(),
        "default_output_extension": attr.string(),
        "depfile": attr.string(),
        "depsformat": attr.string(),
        "description": attr.string(),
        "exe_output_extension": attr.string(),
        "rlib_output_extension": attr.string(),
        "dylib_output_extension": attr.string(),
        "cdylib_output_extension": attr.string(),
        "rust_proc_macro_output_extension": attr.string(),
        "lib_switch": attr.string(),
        "lib_dir_switch": attr.string(),
        "framework_switch": attr.string(),
        "weak_framework_switch": attr.string(),
        "framework_dir_switch": attr.string(),
        "swiftmodule_switch": attr.string(),
        "rust_swiftmodule_switch": attr.string(),
        "outputs": attr.string_list(),
        "partial_outputs": attr.string_list(),
        "pool": attr.string(),
        "link_output": attr.string(),
        "depend_output": attr.string(),
        "output_prefix": attr.string(),
        "precompiled_header_type": attr.string(),
        "rspfile": attr.string(),
        "rspfile_content": attr.string(),
        "runtime_outputs": attr.string_list(),
        "rust_sysroot": attr.string(),
        "dynamic_link_switch": attr.string(),
        "_wrapper": attr.label(allow_files = True, executable = True, cfg = "exec", default = "//gn:tool_wrapper"),
    },
)
