#!/bin/env python3

# pysomr - Python Wrapper for SoMR API
# Copyright (C) 2026  black-sliver
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.

# Still using setup.py (not pure pyproject) because it appears pyproject can't
# - have different compiler options per platform
# - package an extra file (SoMRandomizer.api.*) into the root of the wheel

import os.path
import platform
import shutil
import typing as t
from pathlib import Path

from setuptools import Command, setup
from setuptools.command.build import build
from setuptools.command.build_ext import build_ext


__all__ = ["setup"]


debug_c_args = {
    "unix": ["-Og", "-g"],
    "gcc": ["-Og", "-g"],
}

release_c_args = {
    "unix": ["-Os", "-s", "-ffunction-sections"],
    "gcc": ["-Os", "-s", "-ffunction-sections"],
    "msvc": ["/Os"],
    "mingw32": ["-Os", "-s"],
}

debug_l_args: t.Dict[str, t.List[str]] = {}

release_l_args = {
    "unix": ["-s", "-Wl,--gc-sections", "-Wl,-rpath,$ORIGIN", "-L."],
    "gcc": ["-s", "-Wl,--gc-sections", "-Wl,-rpath,$ORIGIN", "-L."],
}

release_libraries = {
    "msvc": ["SoMRandomizer.api"],
    "unix": [":SoMRandomizer.api.so"],
    "gcc": [":SoMRandomizer.api.so"],
}

c_args = release_c_args
l_args = release_l_args
libraries = release_libraries

if platform.system() == "Darwin":
    for tool in l_args:  # gc-sections not supported by llvm; DLL ext is .dylib
        if "-Wl,--gc-sections" in l_args[tool]:
            l_args[tool].remove("-Wl,--gc-sections")
    for tool in libraries:
        for i, lib in enumerate(l_args[tool]):
            if lib.startswith(":") and lib.endswith(".so"):
                l_args[tool][i] = lib[:-3] + ".dylib"

dll_ext = ".dll" if platform.system() == "Windows" else ".dylib" if platform.system() == "Darwin" else ".so"


class CustomCommand(Command):
    """setuptools command to build and copy the native (AOT) lib to the lib and dist dir"""

    lib_dir: t.Union[Path, None]
    bdist_dir: t.Union[Path, None]

    def initialize_options(self) -> None:
        self.lib_dir = None
        self.bdist_dir = None

    def finalize_options(self) -> None:
        build_step = self.get_finalized_command("build_ext")
        outputs = build_step.get_outputs()
        if outputs:
            self.lib_dir = Path(outputs[0]).parent
        bdist = self.get_finalized_command("bdist_wheel")
        if bdist.bdist_dir is not None:
            self.bdist_dir = Path(bdist.bdist_dir)

    def run(self) -> None:
        # NOTE: we need the DLL here so we can properly link it
        import subprocess

        subprocess.run(
            "dotnet publish SecretOfManaRandomizer/SoMRandomizer.api/",
            shell=True,
            check=True,
        )
        native_lib = f"SoMRandomizer.api{dll_ext}"
        native_lib_src = f"SecretOfManaRandomizer/SoMRandomizer.api/bin/Release/net10.0/native/{native_lib}"
        print(f"copying {native_lib_src} -> {os.path.curdir}")
        shutil.copy(native_lib_src, ".")
        if self.lib_dir:
            print(f"copying {native_lib} -> {self.lib_dir}")
            self.lib_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy(native_lib, self.lib_dir)
        if self.bdist_dir:
            print(f"copying {native_lib} -> {self.bdist_dir}")
            self.bdist_dir.mkdir(parents=True, exist_ok=True)
            shutil.copy(native_lib, self.bdist_dir)


class CustomBuildExt(build_ext):
    """customized build ext that does per-platform compiler flags"""

    def run(self) -> None:
        print("Running custom build extensions")
        super().run()

    def build_extensions(self) -> None:
        c = self.compiler.compiler_type
        if c not in c_args and c not in l_args:
            print("using unknown compiler: " + c)
        if c in c_args:
            for e in self.extensions:
                e.extra_compile_args = c_args[c]
        if c in l_args:
            for e in self.extensions:
                e.extra_link_args = l_args[c]
        if c in libraries:
            for e in self.extensions:
                e.libraries = libraries[c]
        return build_ext.build_extensions(self)


class CustomBuild(build):
    sub_commands = [("build_custom", None)] + build.sub_commands


setup(
    cmdclass={
        "build": CustomBuild,
        "build_ext": CustomBuildExt,
        "build_custom": CustomCommand,
    }
)
