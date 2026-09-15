"""Keep version-pinned release resources from silently selecting newer packages."""
import importlib.util
import io
from pathlib import Path
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("generator", Path(__file__).parents[1] / "scripts/generate-formula.py")
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)


class ReleasePins(unittest.TestCase):
    def test_versioned_metadata_endpoint(self):
        with patch.object(generator.urllib.request, "urlopen", return_value=io.BytesIO(b'{}')) as request:
            generator.get_pypi_metadata("rich", "14.2.0")
        request.assert_called_once_with("https://pypi.org/pypi/rich/14.2.0/json")

    def test_default_endpoint_is_unchanged(self):
        with patch.object(generator.urllib.request, "urlopen", return_value=io.BytesIO(b'{}')) as request:
            generator.get_pypi_metadata("other")
        request.assert_called_once_with("https://pypi.org/pypi/other/json")

    def test_recursive_resources_use_pinned_versions(self):
        calls = []
        def metadata(name, version=None):
            calls.append((name, version))
            return {"info": {"name": name, "requires_dist": ["Rich>=14,<15"] if name == "richless" else []},
                    "urls": [{"packagetype": "sdist", "url": f"https://example.test/{name}-{version}.tar.gz", "digests": {"sha256": "a" * 64}}]}
        with patch.object(generator, "get_pypi_metadata", side_effect=metadata):
            resources = generator.collect_all_deps("richless", {"richless": "0.4.0", "rich": "14.2.0"})
        self.assertEqual(calls, [("richless", "0.4.0"), ("Rich", "14.2.0")])
        self.assertIn("Rich-14.2.0", resources["rich"][1])


if __name__ == "__main__":
    unittest.main()
