import unittest

from dedupe import dedupe


class TestDedupe(unittest.TestCase):
    def test_drops_repeats(self):
        self.assertEqual(dedupe(["a", "b", "a"]), ["a", "b"])


if __name__ == "__main__":
    unittest.main()
