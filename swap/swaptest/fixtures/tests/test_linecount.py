"""The test that already exists. The job says to write the new one in this style."""
import subprocess
import sys
import unittest


class TestPlainOutput(unittest.TestCase):
    def test_counts_three_lines(self):
        r = subprocess.run([sys.executable, "linecount.py", "sample.txt"],
                           capture_output=True, text=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("3 lines", r.stdout)


if __name__ == "__main__":
    unittest.main()
