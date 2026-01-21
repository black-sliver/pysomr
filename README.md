# Python Wrapper for SoMR API

SoMR API is a native (dotnet AOT) build of the Secret of Mana Randomizer.

This is written in cython and compiles to a native cpython module.

## Usage

See `src/pysomr/__init__.pyi` for the API.

Writing a proper documentation is still TODO.

## Installation

`pip install pysomr` from pypi
or install from source via `pip install path/to/pysomr`.

Note that .net10 is required to build the SoMR AOT library and only platforms supported by .net10 AOT are supported by
this library.

## Development / Testing

The cython source is in the root folder. The `src/pysomr/` only contains typing stubs.

Requires setuptools and cython.

For development, you can run python with
```sh
LD_LIBRARY_PATH=../bin/Release/net10.0/native python
```
to find the AOT-built dll, or copy the AOT-built SoMR DLL next to the (temp) lib folder, e.g. ~/.pyxbld/lib*.

And you should be able to use pyximport to build the library on demand
```py
import pyximport; pyximport.install(); import pysomr
```
which is also why the pysomr and the `pysomr.pyx` are in 2 separate folders,
however pyxbld appears to be currently broken with py3.14.

To test/debug `setup.py`, run `pip wheel . -v`.

## Credits

[Original Secret of Mana Randomizer](https://github.com/Moppu/SecretOfManaRandomizer) by moppu et al.
