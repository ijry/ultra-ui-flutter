import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  testWidgets('alert close slot replaces the default close icon',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPAlert(
            title: '提示',
            closable: true,
            closeSlot: const Text('关闭'),
          ),
        ),
      ),
    );

    expect(find.text('关闭'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('calendar footer builder replaces the confirm button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPCalendar(
            show: true,
            footerBuilder: (context, enabled) =>
                Text(enabled ? '自定义确定' : '不可用'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('不可用'), findsOneWidget);
    expect(find.widgetWithText(UPButton, '确认'), findsNothing);
  });

  testWidgets('calendar footer slot replaces the confirm button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPCalendar(
            show: true,
            footerSlot: const Text('静态页脚'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('静态页脚'), findsOneWidget);
    expect(find.widgetWithText(UPButton, '确认'), findsNothing);
  });

  testWidgets('input prefix and suffix builders render custom widgets',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPInput(
            prefixBuilder: (context) => const Text('前'),
            suffixBuilder: (context) => const Text('后'),
          ),
        ),
      ),
    );

    expect(find.text('前'), findsOneWidget);
    expect(find.text('后'), findsOneWidget);
  });

  testWidgets('input prefix and suffix slots render custom widgets',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPInput(
            prefixSlot: const Text('静态前缀'),
            suffixSlot: const Text('静态后缀'),
          ),
        ),
      ),
    );

    expect(find.text('静态前缀'), findsOneWidget);
    expect(find.text('静态后缀'), findsOneWidget);
  });

  testWidgets('checkbox icon slot replaces the built-in mark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPCheckbox(
            usedAlone: true,
            checked: true,
            label: '选项',
            iconSlot: const Text('自定义勾选'),
          ),
        ),
      ),
    );

    expect(find.text('自定义勾选'), findsOneWidget);
  });

  testWidgets('radio icon slot replaces the built-in mark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPRadioGroup(
            value: 'one',
            children: const [
              UPRadio(
                name: 'one',
                label: '选项',
                iconSlot: Text('自定义单选'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('自定义单选'), findsOneWidget);
  });

  testWidgets('form item error slot replaces the validation message',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPFormItem(
            label: '名称',
            errorMessage: '默认错误',
            errorSlot: const Text('自定义错误'),
            child: const Text('输入框'),
          ),
        ),
      ),
    );

    expect(find.text('自定义错误'), findsOneWidget);
    expect(find.text('默认错误'), findsNothing);
  });

  testWidgets('popup trigger slot opens the popup and bottom slot renders',
      (tester) async {
    final popupKey = GlobalKey<UPPopupState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPPopup(
            key: popupKey,
            triggerSlot: const Text('打开弹层'),
            bottomSlot: const Text('底部扩展'),
            child: const Text('弹层内容'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('打开弹层'), findsOneWidget);
    expect(popupKey.currentState!.isShown, isFalse);
    await tester.tap(find.text('打开弹层'));
    await tester.pump();
    expect(popupKey.currentState!.isShown, isTrue);
    expect(find.text('弹层内容'), findsOneWidget);
    expect(find.text('底部扩展'), findsOneWidget);
  });

  testWidgets('avatar default slot replaces the generated avatar content',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPAvatar(text: 'A', child: const Text('头像插槽')),
        ),
      ),
    );

    expect(find.text('头像插槽'), findsOneWidget);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('countdown content builder receives the current time data',
      (tester) async {
    UPCountDownTimeData? received;
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPCountDown(
            time: 3 * 60 * 1000,
            autoStart: false,
            contentBuilder: (context, data) {
              received = data;
              return Text('${data.minutes}分');
            },
          ),
        ),
      ),
    );

    expect(received, isNotNull);
    expect(received!.minutes, 3);
    expect(find.text('3分'), findsOneWidget);
  });

  testWidgets('parse default slot renders when there is no HTML content',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPParse(child: const Text('解析插槽')),
        ),
      ),
    );

    expect(find.text('解析插槽'), findsOneWidget);
  });

  testWidgets('tooltip trigger slot replaces the default trigger child',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPTooltip(
            text: '默认触发',
            triggerSlot: const Text('自定义触发'),
          ),
        ),
      ),
    );

    expect(find.text('自定义触发'), findsOneWidget);
    expect(find.text('默认触发'), findsNothing);
  });

  testWidgets('tabs-pro icon and tab builders are forwarded to the tab strip',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPTabsPro(
            showContent: false,
            list: const [
              {'name': '首页', 'icon': 'home'},
            ],
            iconBuilder: (context, item, keyName, index) => const Text('自定义图标'),
            tabBuilder: (context, item, keyName, index) => const Text('自定义标签'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('自定义图标'), findsOneWidget);
    expect(find.text('自定义标签'), findsOneWidget);
    expect(find.text('首页'), findsNothing);
  });

  testWidgets('upload default slot replaces the built-in picker tile',
      (tester) async {
    var chooses = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPUpload(
            child: const Text('自定义上传'),
            picker: () async => null,
            onChoose: () => chooses++,
          ),
        ),
      ),
    );

    expect(find.text('自定义上传'), findsOneWidget);
    await tester.tap(find.text('自定义上传'));
    await tester.pump();
    expect(chooses, 1);
  });

  testWidgets('upload play and success slots replace their overlays',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPUpload(
            getVideoThumb: true,
            fileList: const [
              {
                'type': 'video',
                'isVideo': true,
                'status': 'success',
                'name': 'clip',
              },
            ],
            playIconSlot: const Text('播放覆盖'),
            successSlot: const Text('成功覆盖'),
          ),
        ),
      ),
    );

    expect(find.text('播放覆盖'), findsOneWidget);
    expect(find.text('成功覆盖'), findsOneWidget);
  });

  testWidgets('table2 header, sort, cell and empty slots replace defaults',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPTable2(
            columns: const [
              {'key': 'name', 'title': '名称', 'sortable': true},
              {'key': 'age', 'title': '年龄'},
            ],
            data: const [
              {'id': 1, 'name': 'Alice', 'age': 20},
            ],
            headerBuilder:
                (context, column, columnIndex, level, tableContext) =>
                    Text('表头-${column['key']}'),
            headerSortBuilder: (context, sortStatus, column, columnIndex, level,
                    tableContext) =>
                const Text('排序插槽'),
            cellBuilder: (context, row, column, prow, rowIndex, columnIndex,
                    level, tableContext) =>
                Text('单元-${row['name']}-${column['key']}'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('表头-name'), findsOneWidget);
    expect(find.text('表头-age'), findsOneWidget);
    expect(find.text('排序插槽'), findsOneWidget);
    expect(find.text('单元-Alice-name'), findsOneWidget);
    expect(find.text('单元-Alice-age'), findsOneWidget);
    expect(find.text('名称'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPTable2(
            columns: const [
              {'key': 'name', 'title': '名称'},
            ],
            emptySlot: const Text('表格空插槽'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('表格空插槽'), findsOneWidget);
    expect(find.text('暂无数据'), findsNothing);
  });

  testWidgets('table2 cellChild slot is used for recursive cell rendering',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPTable2(
            columns: const [
              {'key': 'name', 'title': '名称'},
            ],
            data: const [
              {
                'id': 1,
                'name': '父',
                'children': [
                  {'id': 2, 'name': '子'},
                ],
              },
            ],
            defaultExpandAll: true,
            cellChildBuilder: (context, row, column, prow, rowIndex,
                    columnIndex, level, tableContext) =>
                Text('子单元-${row['name']}'),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('子单元-父'), findsOneWidget);
    expect(find.text('子单元-子'), findsOneWidget);
  });

  testWidgets('slider default and range handle slots render custom widgets',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: Column(
            children: [
              UPSlider(value: 40, child: const Text('自定义滑块')),
              UPSlider(
                isRange: true,
                rangeValue: const [20, 80],
                minSlot: const Text('最小滑块'),
                maxSlot: const Text('最大滑块'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('自定义滑块'), findsOneWidget);
    expect(find.text('最小滑块'), findsOneWidget);
    expect(find.text('最大滑块'), findsOneWidget);
  });

  testWidgets('novel reader content and panel slots replace defaults',
      (tester) async {
    final key = GlobalKey<UPNovelReaderState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: UPNovelReader(
              key: key,
              loading: true,
              loadingSlot: const Text('自定义加载'),
              topSlot: const Text('顶部插槽'),
              toolbarExtraSlot: const Text('工具栏扩展'),
              bottomSlot: const Text('底部插槽'),
              catalogSlot: const Text('目录插槽'),
              settingsSlot: const Text('设置插槽'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('自定义加载'), findsOneWidget);

    // Toolbar slots are mounted only while controls are visible.
    key.currentState!.showControls();
    await tester.pump();
    expect(find.text('顶部插槽'), findsOneWidget);
    expect(find.text('工具栏扩展'), findsOneWidget);
    expect(find.text('底部插槽'), findsOneWidget);

    key.currentState!.openCatalog();
    await tester.pumpAndSettle();
    expect(find.text('目录插槽'), findsOneWidget);

    key.currentState!.closeCatalog();
    await tester.pumpAndSettle();
    key.currentState!.openSettings();
    await tester.pumpAndSettle();
    expect(find.text('设置插槽'), findsOneWidget);
  });

  testWidgets('novel reader empty slot is used in scroll mode', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPNovelReader(
            chapters: const [
              UPNovelChapter(id: 'empty', title: '空章', content: ''),
            ],
            mode: 'scroll',
            emptySlot: const Text('自定义空正文'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('自定义空正文'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsNothing);
  });
}
