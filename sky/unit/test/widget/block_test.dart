import 'package:sky/widgets.dart';
import 'package:test/test.dart';

import '../engine/mock_events.dart';
import 'widget_tester.dart';

final Key blockKey = new Key('test');

void main() {
  test('Cannot scroll a non-overflowing block', () {
    testWidgets((WidgetTester tester) {
      tester.pumpWidget(
        new Block([
          new Container(
            height: 200.0, // less than 600, the height of the test area
            child: new Text('Hello')
          )
        ],
        key: blockKey)
      );
      tester.pump(); // for SizeObservers

      Point middleOfContainer = tester.getCenter(tester.findText('Hello'));
      Point target = tester.getCenter(tester.findElementByKey(blockKey));
      TestPointer pointer = new TestPointer();
      tester.dispatchEvent(pointer.down(target), target);
      tester.dispatchEvent(pointer.move(target + const Offset(0.0, -10.0)), target);

      tester.pump(const Duration(milliseconds: 1));

      expect(tester.getCenter(tester.findText('Hello')) == middleOfContainer, isTrue);

      tester.dispatchEvent(pointer.up(), target);
    });
  });

  test('Can scroll an overflowing block', () {
    testWidgets((WidgetTester tester) {
      tester.pumpWidget(
        new Block([
          new Container(
            height: 2000.0, // more than 600, the height of the test area
            child: new Text('Hello')
          )
        ],
        key: blockKey)
      );
      tester.pump(); // for SizeObservers

      Point middleOfContainer = tester.getCenter(tester.findText('Hello'));
      Point target = tester.getCenter(tester.findElementByKey(blockKey));
      TestPointer pointer = new TestPointer();
      tester.dispatchEvent(pointer.down(target), target);
      tester.dispatchEvent(pointer.move(target + const Offset(0.0, -10.0)), target);

      tester.pump(const Duration(milliseconds: 1));

      expect(tester.getCenter(tester.findText('Hello')) == middleOfContainer, isFalse);

      tester.dispatchEvent(pointer.up(), target);
    });
  });
}
