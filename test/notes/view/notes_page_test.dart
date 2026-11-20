import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pepeganotes/app.dart';

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

  testWidgets('Жесты просмотра, отметки, редактирования и удаления', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());
    const text = 'Первая строка\nВторая строка\nТретья строка';
    final field = find.byType(TextField);
    final save = find.text('Сохранить');
    for (var index = 0; index < 2; index++) {
      await tester.enterText(field, text);
      await tester.tap(save);
      await tester.pumpAndSettle();
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    final tiles = find.byType(ListTile);
    final viewTitle = find.text('Просмотр заметки');
    final star = find.byIcon(Icons.star);

    await tester.tap(tiles.first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(viewTitle, findsOneWidget);
    expect(
      tester.widget<SelectableText>(find.byType(SelectableText)).data,
      text,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(tiles.last);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(tiles.last);
    await tester.pumpAndSettle();
    expect(viewTitle, findsNothing);
    expect(find.descendant(of: tiles.last, matching: star), findsOneWidget);

    await tester.longPress(tiles.last);
    await tester.pumpAndSettle();
    expect(find.text('Редактирование заметки'), findsOneWidget);
    expect(tester.widget<TextField>(field).controller!.text, text);
    await tester.enterText(field, 'Обновлённая заметка');
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Обновлённая заметка'), findsOneWidget);
    expect(find.descendant(of: tiles.last, matching: star), findsOneWidget);

    await tester.drag(tiles.first, const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(tiles, findsOneWidget);
    expect(star, findsOneWidget);

    await tester.drag(tiles, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Обновлённая заметка'), findsOneWidget);
    expect(star, findsNothing);

    await tester.drag(tiles, const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(tiles, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
