import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultra_ui/ultra_ui.dart';

import '../shared/example_demo_block.dart';
import '../shared/example_page_scaffold.dart';

const String _basicContent = '''# 标题1
这是段落文本，包含**粗体**和*斜体*文本。

## 标题2
这是一个链接：[uview-plus](https://ijry.github.io/uview-plus)

### 列表示例
- 列表项1
- 列表项2
- 列表项3

> 这是一个引用块

---

段落中的行内代码： `console.log('Hello World')`''';

const String _codeContent = '''# 代码示例

以下是一个JavaScript函数：

```javascript
function hello(name) {
    console.log('Hello, ' + name + '!');
}

hello('World');
```

以下是一个Python示例：

```python
def hello(name):
    print(f"Hello, {name}!")

hello("World")
```''';

const String _fullAIContent = '''# AI助手回答

你好！我是AI助手，正在为你逐步生成回答内容...

## 问题分析

让我来分析你提出的问题：

1. 需要实现流式内容显示
2. 模拟AI逐步输出文字的效果
3. 使用定时器控制内容显示速度

## 解决方案

我们可以使用以下方法实现：

### 第一步：创建数据模型
```javascript
data() {
  return {
    streamingContent: '',
    isStreaming: false,
    streamTimer: null
  }
}
```

### 第二步：实现流式显示逻辑
```javascript
methods: {
  startStreaming() {
    // 实现流式显示逻辑
  }
}
```

## 总结

以上就是实现流式内容显示的基本方法。通过定时器控制内容逐字显示，可以营造出AI正在思考和逐步输出的效果。

这种交互方式在现代Web应用中非常常见，特别是在AI助手类产品中。

---

*内容生成完毕*''';

class MarkdownPage extends StatefulWidget {
  const MarkdownPage({super.key});

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  String _streamingContent = '';
  bool _isStreaming = false;
  int _streamIndex = 0;
  Timer? _streamTimer;

  @override
  void dispose() {
    // Source clears the interval in beforeDestroy.
    _streamTimer?.cancel();
    super.dispose();
  }

  void _toggleStreaming() {
    if (_isStreaming) {
      _stopStreaming();
    } else {
      _startStreaming();
    }
  }

  void _startStreaming() {
    if (_isStreaming) return;
    if (_streamIndex >= _fullAIContent.length) {
      _streamIndex = 0;
      _streamingContent = '';
    }
    setState(() => _isStreaming = true);
    // Source uses a 50ms interval to mimic token-by-token output.
    _streamTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_streamIndex < _fullAIContent.length) {
        setState(() {
          _streamingContent += _fullAIContent[_streamIndex];
          _streamIndex += 1;
        });
      } else {
        _stopStreaming();
      }
    });
  }

  void _stopStreaming() {
    _streamTimer?.cancel();
    _streamTimer = null;
    if (mounted) setState(() => _isStreaming = false);
  }

  void _resetStreaming() {
    _stopStreaming();
    setState(() {
      _streamingContent = '';
      _streamIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExamplePageScaffold(
      title: 'Markdown',
      child: Container(
        key: const ValueKey('example-page-componentsD/markdown/markdown'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const ExampleDemoBlock(
              title: '基础用法',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPMarkdown(
                  key: ValueKey('markdown-page-basic'),
                  content: _basicContent,
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '带代码块行号',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPMarkdown(
                  key: ValueKey('markdown-page-line-number'),
                  content: _codeContent,
                  showLineNumber: true,
                ),
              ),
            ),
            const ExampleDemoBlock(
              title: '深色主题',
              child: Padding(
                padding: EdgeInsets.all(12),
                child: UPMarkdown(
                  key: ValueKey('markdown-page-dark'),
                  content: _basicContent,
                  theme: 'dark',
                ),
              ),
            ),
            ExampleDemoBlock(
              title: 'AI流式内容显示',
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    UPMarkdown(
                      key: const ValueKey('markdown-page-streaming'),
                      content: _streamingContent,
                      showLineNumber: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        UPButton(
                          key: const ValueKey('markdown-page-stream-toggle'),
                          type: 'primary',
                          size: 'mini',
                          text: _isStreaming ? '停止' : '开始',
                          onClick: _toggleStreaming,
                        ),
                        const SizedBox(width: 10),
                        UPButton(
                          key: const ValueKey('markdown-page-stream-reset'),
                          size: 'mini',
                          text: '重置',
                          onClick: _resetStreaming,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
