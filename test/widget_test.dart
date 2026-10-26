import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepeganotes/main.dart';

void main() {
  testWidgets('Создание, редактирование, отмена и удаление заметок', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    Future<void> save(String text) async {
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.text('Сохранить'));
      await tester.pump();
    }

    await save('   ');
    expect(find.text('Введите текст заметки'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);

    await save(' Первая заметка ');
    await save('Вторая заметка');
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.text('Первая заметка'), findsOneWidget);

    await tester.tap(find.byTooltip('Редактировать').last);
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Изменённая заметка');
    await tester.tap(find.byTooltip('Удалить').first);
    await tester.pump();
    await tester.tap(find.text('Сохранить'));
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Изменённая заметка'), findsOneWidget);
    expect(find.text('Вторая заметка'), findsNothing);

    await tester.tap(find.byTooltip('Редактировать'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Не сохранять');
    await tester.tap(find.text('Отмена'));
    await tester.pump();
    expect(find.text('Изменённая заметка'), findsOneWidget);
    expect(find.text('Не сохранять'), findsNothing);

    await tester.tap(find.byTooltip('Редактировать'));
    await tester.pump();
    await tester.tap(find.byTooltip('Удалить'));
    await tester.pump();
    expect(find.text('Пока нет заметок'), findsOneWidget);
    expect(find.text('Отмена'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(tester.takeException(), isNull);
  });
}
