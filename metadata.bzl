# //gn/* should not be used from rules_gn
# Instead, rules_gn symlinks it into the generated repo.
# Otherwise, static_library(name = "//:foo") would have no
# idea what the default toolchain is.

# Here's a dummy example file so we can add tests directly in rules_gn (and so an LSP doesn't complain).
BUILD_ROOT_DIR = "out/Default"
DEFAULT_TOOLCHAIN = Label("//:dummy_toolchain")