def _source(attrs):
    return _exec_path(attrs["source"])

def _source_file_part(attrs):
    return attrs["source"].basename

def _source_name_part(attrs):
    return attrs["source"].basename.rsplit(".", 1)[0]

def _source_dir(attrs):
    return "../../" + attrs["source"].dirname

def _source_root_relative_dir(attrs):
    return attrs["source"].dirname

def _source_gen_dir(attrs):
    return "%s/%s" % (attrs["toolchain"].root_gen_dir, attrs["source"].dirname)

def _source_out_dir(attrs):
    return "%s/%s" % (attrs["toolchain"].root_out_dir, attrs["source"].dirname)

def _package(attrs):
    package = attrs["ctx"].label.package
    if package:
        return package + "/"
    return ""

def _target_out_dir(attrs):
    return "%s/%s" % (attrs["toolchain"].root_out_dir, _package(attrs))

def _label_name(attrs):
    return attrs["ctx"].label.name

def _exec_path(f):
    if f.is_source:
        return "../../" + f.path

    # strip out/* equivalents
    return f.short_path.split("/", 2)[2]

def _output(attrs):
    return _exec_path(attrs["output"])

_FORMAT = {
    "source_file_part": _source_file_part,
    "source_name_part": _source_name_part,
    "source_dir": _source_dir,
    "source_root_relative_dir": _source_root_relative_dir,
    "source_gen_dir": _source_gen_dir,
    "source_out_dir": _source_out_dir,
    "target_out_dir": _target_out_dir,
    "label_name": _label_name,
    "output": _output,
    "source": _source,
}

def apply_substitutions(preprocessed, attrs):
    fmt, vars = preprocessed
    return fmt % tuple([_FORMAT[v](attrs) for v in vars])

def _defines(args, attrs):
  flags = []
  for c in attrs["configs"]:
    flags.extend(c.defines)
  args.add_all(flags, format_each="-D%s")

def _cflags(args, attrs):
  flags = []
  for c in attrs["configs"]:
    flags.extend(c.cflags)
  args.add_all(flags)

def _cflags_cc(args, attrs):
  flags = []
  for c in attrs["configs"]:
    flags.extend(c.cflags_cc)
  args.add_all(flags)

def _include_dirs(args, attrs):
  flags = []
  for c in attrs["configs"]:
    flags.extend(c.include_dirs)
  args.add_all(flags, format_each="-I%s")

_FILL = {
  "defines": _defines,
  "cflags": _cflags,
  "cflags_cc": _cflags_cc,
  "include_dirs": _include_dirs,
}

def write_command(args, command, attrs):
    for fmt, vars in command:
        if not vars:
            args.add(fmt)
        elif fmt == "%s" and vars[0] not in _FORMAT:
            # It's a more complex substitution
            # TODO
            if vars[0] in _FILL:
              _FILL[vars[0]](args, attrs)
            else:
              print("SKIPPING", fmt, vars)
        elif len(vars) == 1:
            # It's a simple substitution supported by args.add
            args.add(_FORMAT[vars[0]](attrs), format = fmt)
        else:
            # It's multiple substitutions
            args.add(apply_substitutions((fmt, vars), attrs))
