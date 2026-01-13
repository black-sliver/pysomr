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

import os
import os.path
import platform
import shutil
import subprocess
import sys
import typing as t
from pathlib import Path

from setuptools import Command, setup
from setuptools.command.build import build
from setuptools.command.build_ext import build_ext


__all__ = ["CustomCommand", "get_dotnet_os", "get_dotnet_arch"]


is_macos = platform.system() == "Darwin"
is_windows = platform.system() == "Windows"
dll_ext = ".dll" if is_windows else ".dylib" if is_macos else ".so"

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
    "unix": ["-s", "-Wl,--gc-sections", "-Wl,-rpath,$ORIGIN"],
    "gcc": ["-s", "-Wl,--gc-sections", "-Wl,-rpath,$ORIGIN"],
}

release_libraries = {
    "msvc": ["SoMRandomizer.api"],
    "unix": [":SoMRandomizer.api.so"],
    "gcc": [":SoMRandomizer.api.so"],
}

c_args = release_c_args
l_args = release_l_args
libraries = release_libraries
library_dirs = ["."]

if is_macos:
    # macOS (clang) uses some different compiler switches
    c_args_replacements: t.List[t.Tuple[str, t.Union[str, None]]] = [
        ("-s", None),
    ]
    l_args_replacements: t.List[t.Tuple[str, t.Union[str, None]]] = [
        ("-Wl,--gc-sections", None),
        ("-s", None),
        ("-Wl,-rpath,$ORIGIN", "-Wl,-rpath,@loader_path"),
    ]
    for tool in c_args:
        for orig, replacement in c_args_replacements:
            if orig in c_args[tool]:
                c_args[tool].remove(orig)
                if replacement:
                    c_args[tool].append(replacement)
    for tool in l_args:
        for orig, replacement in l_args_replacements:
            if orig in l_args[tool]:
                l_args[tool].remove(orig)
                if replacement:
                    l_args[tool].append(replacement)
    for tool in libraries:
        for i, lib in enumerate(libraries[tool]):
            # For some reason using a direct path doesn't work during link-time on macOS.
            # See explanation in CustomCommand.run.
            if lib.startswith(":SoMRandomizer.api."):
                libraries[tool][i] = "SoMRandomizer-api"
            elif lib.endswith(".so"):
                libraries[tool][i] = lib[:-3] + ".dylib"


def get_dotnet_os() -> str:
    system = platform.system()
    if system == "Windows":
        return "win"
    if system == "Darwin":
        return "osx"
    if system == "Linux":
        libc_ver = platform.libc_ver()
        if "musl" in libc_ver:
            return "linux-musl"
        if "bionic" in libc_ver:
            return "linux-bionic"
        return "linux"
    # TODO: android, ios
    return "unix"


def get_dotnet_arch() -> str:
    # FIXME: there has to be a better way?
    machine = platform.machine().lower()
    if machine in ("x86", "i386", "i586", "i686"):
        return "x86"
    if machine in ("amd64", "x86_64", "x64"):
        if sys.maxsize > 2**32:
            return "x64"
        return "x86"
    if machine in ("arm64", "aarch64"):
        return "arm64"
    if machine.startswith("arm"):
        return "arm"
    raise Exception("Unsupported architecture")


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

    @staticmethod
    def dotnet_publish(rid: t.Optional[str] = None) -> Path:
        if rid is None:
            rid = "-".join((get_dotnet_os(), get_dotnet_arch()))
        if not rid.replace("-", "").isalnum():
            raise ValueError("Invalid rid")

        # contrary to documentation, it appears that we have to explicitly set the RID even for "native"
        # also supplying -r <rid> fails for whatever reason
        with open("SecretOfManaRandomizer/SoMRandomizer.api/SoMRandomizer.api.csproj.user", "w") as f:
            f.write(f"<Project><PropertyGroup><RuntimeIdentifier>{rid}</RuntimeIdentifier></PropertyGroup></Project>")
        dotnet = shutil.which("dotnet")
        native_lib_src_name = f"SoMRandomizer.api{dll_ext}"
        output = Path(f"SecretOfManaRandomizer/SoMRandomizer.api/bin/Release/net10.0/native/{native_lib_src_name}")
        if not dotnet and os.environ.get("CIBUILDWHEEL", None) and output.is_file():
            return output
        assert dotnet, "dotnet not found"
        subprocess.run(
            [dotnet, "publish", "SecretOfManaRandomizer/SoMRandomizer.api/"],
            check=True,
        )
        return output

    def dotnet_publish_universal2(self) -> Path:
        macos_build_dir = Path("build") / "macos"
        macos_build_dir.mkdir(parents=True, exist_ok=True)
        dotnet_os = get_dotnet_os()
        arm64_src = self.dotnet_publish(f"{dotnet_os}-arm64")
        arm64_lib = macos_build_dir / Path(arm64_src).name.replace(".dylib", ".arm64.dylib")
        shutil.move(arm64_src, arm64_lib)
        x64_src = self.dotnet_publish(f"{dotnet_os}-x64")
        x64_lib = macos_build_dir / Path(arm64_src).name.replace(".dylib", ".x64.dylib")
        shutil.move(x64_src, x64_lib)
        universal_lib = macos_build_dir / Path(x64_src).name
        lipo = shutil.which("lipo")
        assert lipo, "lipo not found"
        subprocess.run(
            [lipo, "-output", str(universal_lib), "-create", str(arm64_lib), str(x64_lib)],
            check=True,
        )
        return universal_lib

    def run(self) -> None:
        # NOTE: we need the DLL here so we can properly link it, also we want to package it further down
        if is_macos:
            native_lib_src = self.dotnet_publish_universal2()
        else:
            native_lib_src = self.dotnet_publish()
        native_lib = native_lib_src.name
        print(f"copying {native_lib_src} -> {native_lib} ({os.path.getsize(native_lib_src)})")
        shutil.copy(native_lib_src, native_lib)

        if is_macos:
            # for whatever reason it looks up the correct name during runtime, but can't link it during link time,
            # so we copy the badly-named dll to the name specified above and then ship the badly-named one anyway.
            temp_lib = f"lib{native_lib.replace('.api', '-api')}"
            print(f"copying {native_lib} -> {temp_lib}")
            shutil.copy(native_lib, temp_lib)

        if dll_ext == ".dll":
            # also copy importlib on windows
            import_lib_src = native_lib_src.with_suffix(".lib")
            print(f"copying {import_lib_src} -> {os.path.curdir} ({os.path.getsize(import_lib_src)})")
            shutil.copy(import_lib_src, ".")

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
                e.library_dirs = library_dirs
        return build_ext.build_extensions(self)


class CustomBuild(build):
    sub_commands = [("build_custom", None)] + build.sub_commands


if __name__ == "__main__":
    setup(
        cmdclass={
            "build": CustomBuild,
            "build_ext": CustomBuildExt,
            "build_custom": CustomCommand,
        }
    )
