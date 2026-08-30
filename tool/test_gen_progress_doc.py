import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import gen_progress_doc


class ComponentTotalTest(unittest.TestCase):
    def test_component_totals_only_excludes_present_aggregate(self):
        self.assertEqual(gen_progress_doc.component_total({'u-a': {}}), 1)
        self.assertEqual(
            gen_progress_doc.component_total({'uview-plus': {}, 'u-a': {}}),
            1,
        )


if __name__ == '__main__':
    unittest.main()
