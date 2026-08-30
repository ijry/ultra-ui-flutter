import pathlib
import sys
import tempfile
import unittest
from unittest import mock

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import gen_progress_doc


class ComponentTotalTest(unittest.TestCase):
    def test_component_totals_only_excludes_present_aggregate(self):
        self.assertEqual(gen_progress_doc.component_total({'u-a': {}}), 1)
        self.assertEqual(
            gen_progress_doc.component_total({'uview-plus': {}, 'u-a': {}}),
            1,
        )

    def test_generated_scan_notes_do_not_claim_resolved_gaps_remain(self):
        with tempfile.TemporaryDirectory() as temp:
            output = pathlib.Path(temp) / 'component-progress.md'
            with mock.patch.object(gen_progress_doc, 'OUT', str(output)):
                gen_progress_doc.main()
            markdown = output.read_text(encoding='utf-8')

        self.assertNotIn('仍计入缺失', markdown)
        self.assertNotIn('其余少量缺失', markdown)


if __name__ == '__main__':
    unittest.main()
