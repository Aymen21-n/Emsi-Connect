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
import 'package:emsi_connect/screens/home_page.dart';
import 'package:emsi_connect/screens/login_page.dart';
import 'package:emsi_connect/screens/profile_page.dart';
import 'package:emsi_connect/screens/register_page.dart';

void main() {
  testWidgets('application uses a shared Material 3 theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Connexion'), findsOneWidget);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.useMaterial3, isTrue);
    expect(
      app.theme!.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: Colors.indigo).primary,
    );
    expect(app.theme!.inputDecorationTheme.filled, isTrue);
    expect(app.theme!.inputDecorationTheme.border, isA<OutlineInputBorder>());
    expect(app.theme!.elevatedButtonTheme.style, isNotNull);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'etudiant@emsi.ma',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'motdepasse');
    await tester.tap(find.text('Vérifier la saisie'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenue sur EMSI Connect'), findsOneWidget);
    await tester.tap(find.text('Mes cours'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Activer le thème sombre'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(
      Theme.of(tester.element(find.byType(CoursesPage))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byTooltip('Activer le thème clair'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('login page displays email and obscured password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Connexion'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Adresse email'), findsOneWidget);
    expect(find.text('exemple@emsi.ma'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);

    final passwordInput = tester.widget<EditableText>(
      find.byType(EditableText).last,
    );
    expect(passwordInput.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isFalse,
    );
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();
    expect(
      tester.widget<EditableText>(find.byType(EditableText).last).obscureText,
      isTrue,
    );
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets(
    'valid login navigates through the app and logout returns to login',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      try {
        final emailField = find.byType(TextFormField).at(0);
        final passwordField = find.byType(TextFormField).at(1);
        final verifyButton = find.text('Vérifier la saisie');

        await tester.tap(verifyButton);
        await tester.pumpAndSettle();
        expect(find.text('Email obligatoire'), findsOneWidget);
        expect(find.text('Mot de passe obligatoire'), findsOneWidget);

        await tester.enterText(emailField, 'adresse-invalide');
        await tester.enterText(passwordField, '1234');
        await tester.tap(verifyButton);
        await tester.pumpAndSettle();
        expect(find.text('Email invalide'), findsOneWidget);
        expect(find.text('Au moins 8 caractères'), findsOneWidget);

        await tester.enterText(emailField, 'etudiant@emsi.ma');
        await tester.enterText(passwordField, 'motdepasse');
        await tester.tap(verifyButton);
        await tester.pumpAndSettle();
        expect(find.text('EMSI Connect'), findsOneWidget);
        expect(find.text('Bienvenue sur EMSI Connect'), findsOneWidget);

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(find.text('Étudiant EMSI'), findsOneWidget);
        expect(find.text('etudiant@emsi.ma'), findsOneWidget);
        final drawer = find.byType(Drawer);
        final coursesLink = find.descendant(
          of: drawer,
          matching: find.text('Mes cours'),
        );
        await tester.ensureVisible(coursesLink);
        await tester.tap(coursesLink);
        await tester.pumpAndSettle();
        expect(find.text('Modules du semestre'), findsOneWidget);
        await tester.ensureVisible(find.text('Retour'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();
        expect(find.text('Bienvenue sur EMSI Connect'), findsOneWidget);

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final aboutLink = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('À propos'),
        );
        await tester.ensureVisible(aboutLink);
        await tester.tap(aboutLink);
        await tester.pumpAndSettle();
        expect(find.text('Version pédagogique 1.0'), findsOneWidget);
        expect(find.textContaining('consulter vos cours'), findsOneWidget);
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final profileLink = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Mon profil'),
        );
        await tester.ensureVisible(profileLink);
        await tester.tap(profileLink);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Voir les détails'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Voir les détails'));
        await tester.pumpAndSettle();
        expect(find.text('Aymen Nafis'), findsOneWidget);
        expect(find.text('Informatique'), findsOneWidget);
        await tester.tap(find.text('Retour'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final settingsLink = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Paramètres'),
        );
        await tester.ensureVisible(settingsLink);
        await tester.tap(settingsLink);
        await tester.pumpAndSettle();
        var notificationsSwitch = find.widgetWithText(
          SwitchListTile,
          'Notifications',
        );
        var compactSwitch = find.widgetWithText(SwitchListTile, 'Mode compact');
        expect(
          tester.widget<SwitchListTile>(notificationsSwitch).value,
          isTrue,
        );
        expect(tester.widget<SwitchListTile>(compactSwitch).value, isFalse);
        await tester.tap(find.text('Notifications'));
        await tester.tap(find.text('Mode compact'));
        await tester.pumpAndSettle();
        expect(find.text('Notifications : Désactivées'), findsOneWidget);
        expect(find.text('Mode compact : Activé'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final reopenedSettingsLink = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Paramètres'),
        );
        await tester.ensureVisible(reopenedSettingsLink);
        await tester.tap(reopenedSettingsLink);
        await tester.pumpAndSettle();
        notificationsSwitch = find.widgetWithText(
          SwitchListTile,
          'Notifications',
        );
        compactSwitch = find.widgetWithText(SwitchListTile, 'Mode compact');
        expect(
          tester.widget<SwitchListTile>(notificationsSwitch).value,
          isTrue,
        );
        expect(tester.widget<SwitchListTile>(compactSwitch).value, isFalse);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        final logoutLink = find.descendant(
          of: find.byType(Drawer),
          matching: find.text('Déconnexion'),
        );
        await tester.ensureVisible(logoutLink);
        await tester.tap(logoutLink);
        await tester.pumpAndSettle();
        expect(find.text('Connexion'), findsOneWidget);
        expect(find.text('Adresse email'), findsOneWidget);
      } finally {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    },
  );

  testWidgets('login form width adapts to phone and tablet screens', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    try {
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(Form)).width, lessThanOrEqualTo(288));

      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      final formRect = tester.getRect(find.byType(Form));
      expect(formRect.width, 420);
      expect(formRect.center.dx, 500);
      expect(tester.takeException(), isNull);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });

  testWidgets('registration form validates matching passwords locally', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Inscription'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));

    final nameField = find.byType(TextFormField).at(0);
    final phoneField = find.byType(TextFormField).at(1);
    final emailField = find.byType(TextFormField).at(2);
    final passwordField = find.byType(TextFormField).at(3);
    final confirmationField = find.byType(TextFormField).at(4);
    final submitButton = find.text('Créer mon compte');

    await tester.enterText(nameField, 'Étudiant EMSI');
    await tester.enterText(phoneField, '0612345678');
    await tester.enterText(emailField, 'etudiant@emsi.ma');
    await tester.enterText(passwordField, 'motdepasse');
    await tester.enterText(confirmationField, 'autremotdepasse');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Les mots de passe ne correspondent pas'), findsOneWidget);
    expect(find.text('Formulaire valide — compte non créé'), findsNothing);

    await tester.enterText(confirmationField, 'motdepasse');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();
    expect(find.text('Formulaire valide — compte non créé'), findsOneWidget);
  });

  testWidgets('registration validates numeric phone and counts description', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    final phoneField = find.byType(TextFormField).at(1);
    final descriptionField = find.byType(TextFormField).last;
    await tester.enterText(phoneField, '06123');
    await tester.enterText(descriptionField, 'Étudiant en informatique');
    await tester.pump();

    final phoneInput = tester.widget<EditableText>(
      find.descendant(of: phoneField, matching: find.byType(EditableText)),
    );
    expect(phoneInput.keyboardType, TextInputType.phone);
    expect(find.text('5/10'), findsNothing);
    expect(find.text('24/200'), findsOneWidget);

    final submitButton = find.text('Créer mon compte');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
    expect(find.text('Le téléphone doit contenir 10 chiffres'), findsOneWidget);
  });

  testWidgets('registration form scrolls to the submit button with keyboard', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    try {
      final submitButton = find.text('Créer mon compte');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      expect(tester.getRect(submitButton).bottom, lessThanOrEqualTo(360));
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(find.text('Nom complet obligatoire'), findsOneWidget);
      expect(find.text('Email obligatoire'), findsOneWidget);
      expect(find.text('Mot de passe obligatoire'), findsOneWidget);
      expect(find.text('Confirmez votre mot de passe'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.viewInsets = const FakeViewPadding();
    }
  });

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

  testWidgets('home sections adapt between phone and tablet grids', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    try {
      tester.view.physicalSize = const Size(320, 800);
      await tester.pumpAndSettle();
      var grid = tester.widget<GridView>(find.byType(GridView));
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        2,
      );
      expect(find.text('Mes cours'), findsOneWidget);
      expect(find.text('Planning'), findsOneWidget);
      expect(find.text('Mon profil'), findsOneWidget);
      expect(find.text('Mes tâches'), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.physicalSize = const Size(800, 900);
      await tester.pumpAndSettle();
      grid = tester.widget<GridView>(find.byType(GridView));
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        3,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.notifications));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(tester.takeException(), isNull);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
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

  testWidgets('profile name edit updates the profile and details page', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    try {
      await tester.ensureVisible(find.text('Modifier le nom'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifier le nom'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('Le nom est obligatoire'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Sara El Amrani');
      await tester.tap(find.text('Valider'));
      await tester.pumpAndSettle();
      expect(find.text('Sara El Amrani'), findsOneWidget);
      expect(find.text('Nom : Sara El Amrani'), findsOneWidget);

      await tester.ensureVisible(find.text('Voir les détails'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Voir les détails'));
      await tester.pumpAndSettle();
      expect(find.text('Sara El Amrani'), findsOneWidget);
      expect(find.text('Informatique'), findsOneWidget);
    } finally {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
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
