import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

void main() {
  group('UPUtils.getPx', () {
    test('number passthrough', () {
      expect(UPUtils.getPx(12), 12);
      expect(UPUtils.getPx(12.5), 12.5);
    });

    test('px string', () {
      expect(UPUtils.getPx('12px'), 12);
      expect(UPUtils.getPx('12.5px'), 12.5);
    });

    test('rpx conversion with 375 width', () {
      expect(UPUtils.getPx('750rpx', screenWidth: 375), 375);
      expect(UPUtils.rpx2px(750, screenWidth: 375), 375);
    });
  });

  group('UPTest', () {
    final checker = UPTest();
    test('email', () {
      expect(checker.email('a@b.com'), isTrue);
      expect(checker.email('bad'), isFalse);
    });
    test('mobile', () {
      expect(checker.mobile('13800138000'), isTrue);
      expect(checker.mobile('12345'), isFalse);
    });
  });

  group('defaults', () {
    test('button defaults match source', () {
      const d = UPButtonProps();
      expect(d.type, 'info');
      expect(d.size, 'normal');
      expect(d.shape, 'square');
      expect(d.hairline, isFalse);
      expect(d.loadingSize, 15);
      expect(d.hoverStayTime, 200);
    });

    test('icon defaults match source', () {
      const d = UPIconProps();
      expect(d.size, '16px');
      expect(d.customPrefix, 'uicon');
      expect(d.labelPos, 'right');
      expect(d.space, '3px');
    });
  });
}
