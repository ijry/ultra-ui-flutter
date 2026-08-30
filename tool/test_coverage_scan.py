import contextlib
import io
import json
import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import coverage_scan


class IntentionalMethodExclusionTest(unittest.TestCase):
    def test_component_scoped_exclusions_do_not_hide_real_method_gaps(self):
        excluded = {
            'u-parse': ['_hook', '_onMessage', '_set'],
            'u-qrcode': ['_empty', '_queueMakeCode'],
            'u-novel-reader': [
                'articleStyle',
                'catalogPopupStyle',
                'catalogStyle',
                'disabledColor',
                'mutedColor',
                'paragraphStyle',
                'readerStyle',
                'settingsPopupStyle',
                'settingsStyle',
                'textColor',
                'themeOptionStyle',
                'toolbarStyle',
            ],
        }
        classes = {
            'u-parse': 'UPParse',
            'u-qrcode': 'UPQrcode',
            'u-novel-reader': 'UPNovelReader',
        }

        with tempfile.TemporaryDirectory() as temp:
            root = pathlib.Path(temp)
            src = root / 'src'
            dst = root / 'dst'
            src.mkdir()
            dst.mkdir()

            for component, internal_methods in excluded.items():
                component_dir = src / component
                component_dir.mkdir()
                method_source = '\n'.join(
                    f'    {name}() {{}}' for name in internal_methods
                )
                (component_dir / f'{component}.vue').write_text(
                    '<script>\n'
                    'export default {\n'
                    '  methods: {\n'
                    f'{method_source}\n'
                    '    publicMethod() {}\n'
                    '    hostVisible() {}\n'
                    '  }\n'
                    '}\n'
                    '</script>\n',
                    encoding='utf-8',
                )
                dart_name = component.replace('-', '_') + '.dart'
                (dst / dart_name).write_text(
                    f'class {classes[component]} {{\n'
                    '  void publicMethod() {}\n'
                    '}\n',
                    encoding='utf-8',
                )

            original_src = coverage_scan.SRC
            original_dst = coverage_scan.DST
            coverage_scan.SRC = str(src)
            coverage_scan.DST = str(dst)
            try:
                output = io.StringIO()
                with contextlib.redirect_stdout(output):
                    self.assertEqual(coverage_scan.main(), 0)
                report = json.loads(output.getvalue())
            finally:
                coverage_scan.SRC = original_src
                coverage_scan.DST = original_dst

        for component, internal_methods in excluded.items():
            with self.subTest(component=component):
                self.assertEqual(report[component]['missing_methods'], ['hostVisible'])
                self.assertEqual(
                    report[component]['excluded_methods'], internal_methods
                )


if __name__ == '__main__':
    unittest.main()
