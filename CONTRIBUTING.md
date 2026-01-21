# pysomr Contribution Guidelines

Development happens on https://github.com/black-sliver/pysomr .

The API is not stable, so it may be better to just leave a suggestion in an issue or on the SoMR Discord for now.

If you open a PR, please consider allowing me to switch licenses in the future by including this sentence:

> I hereby grant the original author of pysomr, black-sliver, permission to relicense (publish under a different
> license) my contributions under the terms of GNU Lesser General Public License 2.1 (LGPL2.1) or newer,
> or Eclipse Public License 2.0 (EPL2).

Other parts of the software stack may be EPL2 or a newer version of (L)GPL and if an opportunity to merge or move code
between parts arises, I would like to be able to.

## Running Linters

We use black for auto-formatting, mypy for type checking and codespell to find typos.
See pyproject.toml for tool configuration. Install and run everything with
```shell
pip install -r linter_requirements.txt > /dev/null
cython-lint .
black .
mypy --strict *.py src examples
flake8 *.py src examples
codespell
```

Note: all those things are also checked in CI.

### Clean up the venv

```shell
# if you've run `pip install .`
rm -R .venv/lib/*/site-packages/pysomr*
```
