# homebrew-tools
Publish tools I wrote via homebrew for MacOS/Linux


## Regenerate richless

The richless template pins its release and tested dependency versions. Update
`[versions]` deliberately when preparing a release; the generator's default
latest-version mode does not resolve dependency constraints.

```sh
uv run python scripts/generate-formula.py templates/richless.toml > Formula/richless.rb
uv run python -m unittest discover -s tests -v
```

Generate only after the matching release is available on PyPI. The formula's
caveats use the stable Homebrew prefix so future upgrades do not leave shell
startup files pointing at a removed Cellar version.
