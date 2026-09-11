import unittest

from wordfreq import counts


class TestWordFreq(unittest.TestCase):
    def test_case_insensitive(self):
        self.assertEqual(counts("The the THE")["the"], 3)


if __name__ == "__main__":
    unittest.main()
