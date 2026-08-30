import json
import pathlib
import sys
import tempfile
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).parent))
import gen_replication_progress


class PagesJsonParserTest(unittest.TestCase):
    def test_load_pages_json_ignores_commented_routes_and_flattens_packages(self):
        content = r'''
        {
          // "path": "pages/ignored/route"
          "pages": [
            {"path": "pages/example/components", "style": {"navigationBarTitleText": "首页"}},
          ],
          "subPackages": [
            {"root": "pages/componentsA", "pages": [
              {"path": "icon/icon", "style": {"navigationBarTitleText": "图标"}},
              // {"path": "commented/commented"},
            ]},
          ],
        }
        '''
        with tempfile.TemporaryDirectory() as temp:
            path = pathlib.Path(temp) / "pages.json"
            path.write_text(content, encoding="utf-8")
            routes = gen_replication_progress.load_pages_json(path)

        self.assertEqual(
            [(route["path"], route["group"], route["title"]) for route in routes],
            [
                ("pages/example/components", "main", "首页"),
                ("pages/componentsA/icon/icon", "componentsA", "图标"),
            ],
        )


class FlutterCatalogParserTest(unittest.TestCase):
    def test_parse_flutter_catalog_resolves_builder_to_imported_page_file(self):
        content = """
        import '../pages/components_a/icon_page.dart';
        import '../pages/home/components_home_page.dart';

        final routes = <ExampleRoute>[
          const ExampleRoute(
            id: 'componentsA/icon/icon',
            sourcePath: 'pages/componentsA/icon/icon',
            title: '图标',
            group: ExampleRouteGroup.componentsA,
            builder: _buildIcon,
          ),
        ];

        Widget _buildIcon(BuildContext context) => const IconPage();
        """
        with tempfile.TemporaryDirectory() as temp:
            path = pathlib.Path(temp) / "example_catalog.dart"
            path.write_text(content, encoding="utf-8")
            routes = gen_replication_progress.parse_flutter_catalog(path)

        self.assertEqual(len(routes), 1)
        self.assertEqual(routes[0]["id"], "componentsA/icon/icon")
        self.assertEqual(routes[0]["page_class"], "IconPage")
        self.assertEqual(routes[0]["page_file"], "example/lib/pages/components_a/icon_page.dart")


class InventoryValidationTest(unittest.TestCase):
    def test_page_inventory_marks_missing_and_extra_routes_explicitly(self):
        source = [
            {
                "path": "pages/componentsA/icon/icon",
                "group": "componentsA",
                "title": "图标",
            },
            {
                "path": "pages/componentsA/missing/missing",
                "group": "componentsA",
                "title": "缺失",
            },
        ]
        flutter = [
            {
                "id": "componentsA/icon/icon",
                "source_path": "pages/componentsA/icon/icon",
                "group": "componentsA",
                "title": "图标",
                "page_file": "example/lib/pages/components_a/icon_page.dart",
                "page_class": "IconPage",
            },
            {
                "id": "componentsD/extra/extra",
                "source_path": "pages/componentsD/extra/extra",
                "group": "componentsD",
                "title": "额外",
                "page_file": "example/lib/pages/components_d/extra_page.dart",
                "page_class": "ExtraPage",
            },
        ]

        records = gen_replication_progress.build_page_inventory(source, flutter)

        self.assertEqual(
            [(record["path"], record["status"]) for record in records],
            [
                ("pages/componentsA/icon/icon", "✅ 已复刻"),
                ("pages/componentsA/missing/missing", "⛔ 未复刻"),
                ("pages/componentsD/extra/extra", "🆕 Flutter 扩展"),
            ],
        )
        self.assertEqual(records[0]["route_compatibility"], "同名路由")
        self.assertEqual(records[1]["route_compatibility"], "缺少 Flutter 路由")
        self.assertEqual(records[2]["route_compatibility"], "仅 Flutter 注册")
        self.assertEqual(records[1]["flutter_route"], "—")
        self.assertEqual(records[2]["source_file"], "—")

    def test_duplicate_route_ids_fail_fast(self):
        duplicate = [
            {"id": "same", "source_path": "pages/same", "group": "main", "title": "A"},
            {"id": "same", "source_path": "pages/other", "group": "main", "title": "B"},
        ]
        with self.assertRaisesRegex(ValueError, "duplicate Flutter route"):
            gen_replication_progress.build_page_inventory([], duplicate)

    def test_component_inventory_preserves_every_coverage_entry(self):
        coverage = {
            "u-icon": {
                "dart_class": "UPIcon",
                "dart_file": "up_icon.dart",
                "props_total": 1,
                "emits_total": 0,
                "methods_total": 1,
                "missing_props": [],
                "missing_emits": [],
                "missing_methods": [],
            },
            "uview-plus": {},
        }
        records = gen_replication_progress.build_component_inventory(coverage, {})
        self.assertEqual([record["name"] for record in records], ["u-icon"])


class MarkdownRenderingTest(unittest.TestCase):
    def test_render_contains_component_and_page_tables(self):
        markdown = gen_replication_progress.render_markdown(
            {
                "components": [
                    {
                        "group": "基础组件",
                        "name": "u-icon",
                        "source_path": "src/uni_modules/uview-plus/components/u-icon",
                        "dart_class": "UPIcon",
                        "dart_file": "packages/ultra_ui/lib/src/widgets/up_icon.dart",
                        "status": "✅ 已复刻",
                        "props": "1/1",
                        "emits": "—",
                        "methods": "1/1",
                        "slots": "—",
                        "demos": "icon/icon",
                        "tests": "未扫描",
                        "notes": "接口与样式对齐",
                    }
                ],
                "pages": [
                    {
                        "group": "componentsA",
                        "path": "pages/componentsA/icon/icon",
                        "title": "图标",
                        "source_file": "src/pages/componentsA/icon/icon.nvue",
                        "config_group": "基础组件",
                        "flutter_route": "componentsA/icon/icon",
                        "flutter_page_file": "example/lib/pages/components_a/icon_page.dart",
                        "status": "✅ 已复刻",
                        "components": "u-icon",
                        "tests": "未扫描",
                        "notes": "",
                    }
                ],
                "unregistered_source_files": [],
                "summary": {
                    "source_components": 1,
                    "pages_json_routes": 1,
                    "flutter_routes": 1,
                    "flutter_source_manifest_routes": 1,
                },
            }
        )
        self.assertIn("## 组件清单", markdown)
        self.assertIn("## 演示页面清单", markdown)
        self.assertIn("u-icon", markdown)
        self.assertIn("pages/componentsA/icon/icon", markdown)
        self.assertIn("路由兼容性", markdown)
        self.assertIn("| 分组 |", markdown)


class RepositoryInventoryTest(unittest.TestCase):
    def setUp(self):
        self.repo = pathlib.Path(__file__).resolve().parents[1]
        self.upstream = self.repo.parent / "uview-plus"
        if not (self.upstream / "src/pages.json").is_file():
            self.skipTest("sibling uview-plus checkout is not available")

    def test_real_route_registries_have_explicit_two_page_extension(self):
        source = gen_replication_progress.load_pages_json(
            self.upstream / "src/pages.json"
        )
        flutter = gen_replication_progress.parse_flutter_catalog(
            self.repo / "example/lib/routes/example_catalog.dart"
        )
        source_paths = {route["path"] for route in source}
        flutter_paths = {route["source_path"] for route in flutter}
        self.assertEqual(len(source), 126)
        self.assertEqual(len(flutter), 128)
        self.assertEqual(
            flutter_paths - source_paths,
            {
                "pages/componentsD/tabsPro/tabsPro",
                "pages/componentsD/rootToastHost/rootToastHost",
            },
        )
        self.assertEqual(source_paths - flutter_paths, set())

    def test_real_demo_configs_and_unregistered_files_are_counted(self):
        components = gen_replication_progress.parse_demo_config(
            self.upstream / "src/pages/example/components.config.js"
        )
        templates = gen_replication_progress.parse_demo_config(
            self.upstream / "src/pages/example/template.config.js",
            template=True,
        )
        source = gen_replication_progress.load_pages_json(
            self.upstream / "src/pages.json"
        )
        self.assertEqual(len(components), 103)
        self.assertEqual(len(templates), 11)
        unregistered = gen_replication_progress.find_unregistered_source_files(
            self.upstream, source
        )
        self.assertEqual(len(unregistered), 9)
        self.assertIn(
            "src/pages/template/douyin/index.nvue",
            {item["path"] for item in unregistered},
        )

    def test_real_component_inventory_has_all_slots_and_components(self):
        coverage = json.loads(
            (self.repo / ".scan/cov.json").read_text(encoding="utf-8")
        )
        groups = json.loads(
            (self.repo / ".scan/groups.json").read_text(encoding="utf-8")
        )
        source_dir = self.upstream / "src/uni_modules/uview-plus/components"
        names = sorted(
            path.name
            for path in source_dir.iterdir()
            if path.is_dir() and path.name.startswith("u-")
        )
        records = gen_replication_progress.build_component_inventory(
            coverage,
            groups,
            source_component_names=names,
            source_components_dir=source_dir,
            dart_widgets_dir=self.repo / "packages/ultra_ui/lib/src/widgets",
            repo_root=self.repo,
        )
        self.assertEqual(len(records), 141)
        self.assertTrue(all(record["status"] == "✅ 已复刻" for record in records))
        self.assertEqual(
            sum(
                int(record["slots"].split("/", 1)[0])
                for record in records
                if record["slots"] != "—"
            ),
            198,
        )


if __name__ == "__main__":
    unittest.main()
