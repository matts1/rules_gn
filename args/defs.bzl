def _fmodule_file(module):
  return "-fmodule-file=%s=%s" % (module.name, module.file)

def _fmodule_map_file(module):
  return "-fmodule-map-file=%s" % module.modulemap.path

def _fill_module_deps_no_self(self, ctx, args):
  self.transitive_inputs.append(self.cc_info.modulemap_files)
  args.add_all(self.cc_info.module_deps_no_self, map_each=_fmodulemap_file)
  args.add_all(self.cc_info.module_deps_no_self, map_each=_fmodule_file)

def _fill_module_deps(self, ctx, args):
  _fill_module_deps_no_self(self, ctx, args)
  self.direct_inputs.append(self.module_file)
  args.add("-fmodule-map-file=%s" % self.modulemap_file)
  args.add("-fmodule-file=%s=%s" % (self.module_name, self.module_file))

def _fill_cflags(self, ctx, args):
  args.add_all(self.cc_info.cflags)

def _fill_cflags_cc(self, ctx, args):
  args.add_all(self.cc_info.cflags_cc)

def _fill_defines(self, ctx, args):
  args.add_all(self.cc_info.defines)



# Fill contains the implementation for nontrivial values that can't be expressed as args.add(value).
# Fill does not return anything and instead 
_FILL = {
  "module_deps": _fill_module_deps,
  "module_deps_no_self": _fill_module_deps_no_self,
  "cflags": _fill_cflags,
  "cflags_cc": _fill_cflags_cc,
  "defines": _fill_defines,
}

def _format_source(self):
  self.direct_inputs.append(self.source)
  return self.source

def _format_output(self):
  return self.output

# Format contains the implementation for simple values that can be expressed as args.add(value).
# Each value is a function that returns an argument suitable for args.add(value).
# eg. file, string, int, bool
_FORMAT = {
  "source": _format_source
}

def to_bazel_args(ctx, self, preprocessed_command):
    args = ctx.actions.args()
    for fmt, vars in args:
        if not vars:
            # It's a string literal
            args.add(fmt)
        elif len(vars) == 1:
            if fmt == '%s' and vars[0] in _FILL:
                # This is be a more complex value such as {{defines}} which is actually a list
                # It has custom logic on how to format it.
                _FILL[vars[0]](self, ctx, args)
            else:
                # This is a simple variable such as {{output}}.d which can be expressed as args.add("%s.d", output)
                args.add(fmt, _FORMAT[vars[0]](self))
        else:
            # This is a multi-variable substitution. Eg. {{output_dir}}/{{target_output_name}}
            # Bazel can't handle this with the Args API, so we need to do it manually.
            args.add(fmt % [_FORMAT[v](self) for v in vars])
            

    return out

