#!/usr/bin/env python3

import json
import os
import shlex
import subprocess
import sys
import tempfile

with open(sys.argv[1], "r") as depfile:
    content = json.load(depfile)
    bazel_inputs = content["bazel_inputs"]
    ninja_inputs = content["ninja_inputs"]
    bazel_outputs = content["bazel_outputs"]
    ninja_outputs = content["ninja_outputs"]

cmd = shlex.split(sys.argv[2])

with tempfile.TemporaryDirectory() as td:
    td = os.path.join(td, "out/Default")
    os.makedirs(td)
    for bazel, ninja in zip(bazel_inputs, ninja_inputs):
        ninja = os.path.join(td, ninja)
        os.makedirs(os.path.dirname(ninja), exist_ok = True)
        os.symlink(os.path.relpath(bazel, start=ninja), ninja)

    for ninja in ninja_outputs:
        os.makedirs(os.path.join(td, os.path.dirname(ninja)), exist_ok = True)

    ps = subprocess.run(cmd, cwd = td)
    if ps.returncode != 0:
        exit(ps.returncode)
    
    for bazel, ninja in zip(bazel_outputs, ninja_outputs):
        ninja = os.path.join(td, ninja)
        try:
            os.rename(ninja, bazel)
        except FileNotFoundError:
            raise FileNotFoundError(f"Ninja action did not generate {ninja}")