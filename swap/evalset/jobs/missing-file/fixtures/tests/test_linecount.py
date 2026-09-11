import subprocess
import sys
import unittest


class TestLineCount(unittest.TestCase):
    def test_counts_three(self):
        r = subprocess.run([sys.executable, "linecount.py", "sample.txt"],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0)
        self.assertIn("3 lines", r.stdout)


if __name__ == "__main__":
    unittest.main()
