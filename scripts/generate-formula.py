#!/usr/bin/env python3
"""Generate a Homebrew formula for a Python package from PyPI metadata.

No external dependencies required — uses only the stdlib and PyPI JSON API.

Usage:
    python3 scripts/generate-formula.py templates/richless.toml > Formula/richless.rb
"""

import json
import re
import sys
import tomllib
import urllib.request


def get_pypi_metadata(package):
    url = f"https://pypi.org/pypi/{package}/json"
    with urllib.request.urlopen(url) as resp:
        return json.loads(resp.read())


def get_sdist(metadata):
    for entry in metadata["urls"]:
        if entry["packagetype"] == "sdist":
            return entry["url"], entry["digests"]["sha256"]
    raise RuntimeError(f"No sdist found on PyPI for {metadata['info']['name']}")


def normalize(name):
    """Normalize package name per PEP 503."""
    return re.sub(r"[-_.]+", "-", name).lower()


def to_class_name(package):
    """Convert package name to Ruby class name (e.g. 'my-tool' -> 'MyTool')."""
    return "".join(word.capitalize() for word in re.split(r"[-_.]+", package))


def get_runtime_deps(metadata):
    """Extract runtime dependency names from PyPI metadata (no extras)."""
    deps = []
    for req in metadata["info"].get("requires_dist") or []:
        if "extra ==" in req:
            continue
        match = re.match(r"^([A-Za-z0-9]([A-Za-z0-9._-]*[A-Za-z0-9])?)", req)
        if match:
            deps.append(match.group(1))
    return deps


def collect_all_deps(package):
    """Recursively collect all runtime dependencies via PyPI API.

    Returns a dict of {normalized_name: (canonical_name, sdist_url, sha256)}.
    """
    result = {}
    to_visit = [package]
    seen = {normalize(package)}

    while to_visit:
        pkg = to_visit.pop()
        meta = get_pypi_metadata(pkg)
        norm = normalize(meta["info"]["name"])

        if norm != normalize(package):
            sdist_url, sdist_sha = get_sdist(meta)
            result[norm] = (meta["info"]["name"], sdist_url, sdist_sha)

        for dep in get_runtime_deps(meta):
            dep_norm = normalize(dep)
            if dep_norm not in seen:
                seen.add(dep_norm)
                to_visit.append(dep)

    return result


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <config.toml>", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1], "rb") as f:
        config = tomllib.load(f)

    package = config["package"]
    python_dep = config.get("python", "python@3.13")
    license_id = config["license"]
    github = config.get("github")
    install_extra = config.get("install_extra", "").strip("\n")
    caveats = config.get("caveats", "").strip("\n")
    test = config.get("test", "").strip("\n")

    metadata = get_pypi_metadata(package)
    info = metadata["info"]
    desc = info["summary"]
    homepage = info.get("home_page") or (github if github else "")
    sdist_url, sdist_sha = get_sdist(metadata)

    deps = collect_all_deps(package)
    resources = sorted(deps.values(), key=lambda r: r[0].lower())

    class_name = to_class_name(package)

    print(f'class {class_name} < Formula')
    print('  include Language::Python::Virtualenv')
    print()
    print(f'  desc "{desc}"')
    print(f'  homepage "{homepage}"')
    print(f'  url "{sdist_url}"')
    print(f'  sha256 "{sdist_sha}"')
    print(f'  license "{license_id}"')
    if github:
        print(f'  head "{github}.git", branch: "main"')
    print()
    print(f'  depends_on "{python_dep}"')

    for name, url, sha in resources:
        print()
        print(f'  resource "{name}" do')
        print(f'    url "{url}"')
        print(f'    sha256 "{sha}"')
        print(f'  end')

    print()
    print('  def install')
    print('    virtualenv_install_with_resources')
    if install_extra:
        print()
        print(install_extra)
    print('  end')

    if caveats:
        print()
        print('  def caveats')
        print('    <<~EOS')
        print(caveats)
        print('    EOS')
        print('  end')

    print()
    if test:
        print('  test do')
        print(test)
        print('  end')
    else:
        print('  test do')
        print(f'    assert_match "usage", shell_output("{{bin}}/{package} --help", 0)')
        print('  end')

    print()
    print('end')


if __name__ == "__main__":
    main()
