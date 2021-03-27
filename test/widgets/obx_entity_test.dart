import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:styx/src/system.dart';

import '../data/data.dart';

final system = EntitySystem();

void main() {
  testWidgets('Does Obx rebuild?', (WidgetTester tester) async {
    var entity = system.create();
    entity += NameComponent('Tester');

    await tester.pumpWidget(TestApp());

    final textFinder = find.text('Tester');
    final textFinder2 = find.text('Tester2');

    /// Expect the original name.
    expect(textFinder, findsOneWidget);

    /// Update name.
    entity.get<NameComponent>().name('Tester2');

    /// Trigger a new frame rebuild.
    await tester.pump();

    /// Did the name change?
    expect(textFinder2, findsOneWidget);
  });
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TesterWidget(),
        ),
      ),
    );
  }
}

class TesterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final matched = system.entities
          .where(
            (e) => e().has<NameComponent>(),
          )
          .toList();
      return Text(
        matched.first().get<NameComponent>().name(),
        key: ValueKey('testWidget'),
      );
    });
  }
}
