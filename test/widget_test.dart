// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:emsi_connect/main.dart';
import 'package:emsi_connect/screens/courses_page.dart';
import 'package:emsi_connect/screens/profile_page.dart';

void main() {
  testWidgets('course tiles show a snackbar with the selected module', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(280, 640);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: CoursesPage()));

    try {
      final firstModule = find.text(
        'Développement d’applications mobiles multiplateformes',
      );
      await tester.ensureVisible(firstModule);
      await tester.pumpAndSettle();
      expect(find.text('Mme Aouraghe · 32 h'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(tester.getRect(firstModule).right, lessThanOrEqualTo(280));

      for (final module in [
        'Développement d’applications mobiles multiplateformes',
        'Sécurité informatique',
        'Intelligence artificielle',
      ]) {
        final moduleFinder = find.text(module);
        await tester.ensureVisible(moduleFinder);
        await tester.pumpAndSettle();
        await tester.tap(moduleFinder);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Module sélectionné : $module'), findsOneWidget);
      }

      expect(tester.takeException(), isNull);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('builder includes the added modules and handles their tap', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: CoursesPage()));

    try {
      final courseList = tester.widget<ListView>(find.byType(ListView));
      expect(courseList.childrenDelegate.estimatedChildCount, 14);

      final heading = find.text('Modules du semestre');
      expect(heading, findsOneWidget);
      final headingTop = tester.getTopLeft(heading).dy;
      final lastModule = find.text('Cloud computing');
      await tester.scrollUntilVisible(
        lastModule,
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.ensureVisible(lastModule);
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(heading).dy, headingTop);
      await tester.tap(lastModule);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Module sélectionné : Cloud computing'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('home sections fit on a narrow screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MyApp());

    const labels = ['Mes cours', 'Planning', 'Mon profil', 'Mes tâches'];
    final widths = <double>[];
    final bounds = <(Offset, Size)>[];

    for (final label in labels) {
      expect(find.text(label), findsOneWidget);
      final sectionFinder = find
          .ancestor(of: find.text(label), matching: find.byType(Container))
          .first;
      final section = tester.widget<Container>(sectionFinder);
      expect(section.padding, const EdgeInsets.all(16));
      expect(section.decoration, isA<BoxDecoration>());
      final decoration = section.decoration! as BoxDecoration;
      expect(decoration.color, Colors.blue.shade50);
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isA<Border>());
      final size = tester.getSize(sectionFinder);
      widths.add(size.width);
      bounds.add((tester.getTopLeft(sectionFinder), size));
    }

    expect(widths[0], widths[1]);
    expect(widths[2], widths[3]);
    expect(bounds[1].$1.dx - (bounds[0].$1.dx + widths[0]), 12);
    expect(bounds[3].$1.dx - (bounds[2].$1.dx + widths[2]), 12);
    expect(bounds[2].$1.dy - (bounds[0].$1.dy + bounds[0].$2.height), 12);

    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('profile page displays the profile information', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    expect(find.text('Mon profil'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    final cardFinder = find.byKey(const ValueKey('student-card'));
    expect(cardFinder, findsOneWidget);
    expect(tester.getSize(cardFinder).width, lessThanOrEqualTo(272));
    expect(find.text('Aymen Nafis'), findsOneWidget);
    expect(find.text('Informatique · S5'), findsOneWidget);
    expect(find.text('N° étudiant : EMSI-2026-0042'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance), findsNWidgets(2));
    expect(find.text('Informations personnelles'), findsOneWidget);
    expect(find.text('Nom : Aymen Nafis'), findsOneWidget);
    expect(find.text('Filière : Informatique'), findsOneWidget);
    expect(find.text('Niveau : S5'), findsOneWidget);
    expect(find.text('Email : Aymen@gmail.com'), findsOneWidget);
    expect(find.text('Année universitaire : 2026–2027'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.byIcon(Icons.class_), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/profil.jpg',
      ),
      findsNWidgets(2),
    );
    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.text('Contacter'), findsOneWidget);
    final firstButton = tester.getRect(find.text('Modifier le profil'));
    final secondButton = tester.getRect(find.text('Contacter'));
    expect(firstButton.left, greaterThanOrEqualTo(0));
    expect(secondButton.right, lessThanOrEqualTo(320));
    expect(firstButton.center.dy, secondButton.center.dy);

    for (final information in [
      'Nom : Aymen Nafis',
      'Filière : Informatique',
      'Niveau : S5',
      'Email : Aymen@gmail.com',
      'Année universitaire : 2026–2027',
    ]) {
      final textFinder = find.text(information);
      expect(tester.getRect(textFinder).left, greaterThanOrEqualTo(0));
      expect(tester.getRect(textFinder).right, lessThanOrEqualTo(320));
    }

    await tester.ensureVisible(find.text('Modifier le profil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modifier le profil'));
    await tester.pump();
    await tester.tap(find.text('Contacter'));
    await tester.pump();
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('Row icon spacing changes with main axis alignment', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 200);
    tester.view.devicePixelRatio = 1;

    Future<List<double>> iconPositions(MainAxisAlignment alignment) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 300,
                height: 48,
                child: Row(
                  mainAxisAlignment: alignment,
                  children: const [
                    Icon(Icons.star),
                    Icon(Icons.star),
                    Icon(Icons.star),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      return List.generate(
        3,
        (index) => tester.getTopLeft(find.byIcon(Icons.star).at(index)).dx,
      );
    }

    final between = await iconPositions(MainAxisAlignment.spaceBetween);
    final around = await iconPositions(MainAxisAlignment.spaceAround);
    final evenly = await iconPositions(MainAxisAlignment.spaceEvenly);

    expect(between[1] - between[0], closeTo(138, 0.1));
    expect(around[1] - around[0], closeTo(100, 0.1));
    expect(evenly[1] - evenly[0], closeTo(81, 0.1));
    expect(tester.takeException(), isNull);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
