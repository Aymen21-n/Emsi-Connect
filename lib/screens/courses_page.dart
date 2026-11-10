import 'package:flutter/material.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key, this.isDarkMode = false, this.onToggleTheme});

  final bool isDarkMode;
  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    const List<Map<String, Object>> modules = [
      {
        'nom': 'Développement d’applications mobiles multiplateformes',
        'enseignant': 'Mme Aouraghe',
        'heures': 32,
      },
      {
        'nom': 'Bases de données avancées',
        'enseignant': 'M. El Amrani',
        'heures': 48,
      },
      {
        'nom': 'Sécurité informatique',
        'enseignant': 'M. El Amrani',
        'heures': 36,
      },
      {
        'nom': 'Architecture des ordinateurs',
        'enseignant': 'M. Tazi',
        'heures': 36,
      },
      {
        'nom': 'Intelligence artificielle',
        'enseignant': 'Mme Bennis',
        'heures': 42,
      },
      {
        'nom': 'Réseaux informatiques',
        'enseignant': 'M. Exemple',
        'heures': 24,
      },
      {
        'nom': 'Programmation orientée objet',
        'enseignant': 'M. Tazi',
        'heures': 40,
      },
      {'nom': 'Génie logiciel', 'enseignant': 'Mme Bennis', 'heures': 40},
      {'nom': 'Développement Web', 'enseignant': 'Mme Aouraghe', 'heures': 36},
      {
        'nom': 'Systèmes d’exploitation',
        'enseignant': 'M. Exemple',
        'heures': 36,
      },
      {
        'nom': 'Analyse et conception',
        'enseignant': 'M. El Amrani',
        'heures': 30,
      },
      {'nom': 'Gestion de projets', 'enseignant': 'M. Tazi', 'heures': 30},
      {'nom': 'Cybersécurité', 'enseignant': 'Mme Bennis', 'heures': 32},
      {'nom': 'Cloud computing', 'enseignant': 'M. Exemple', 'heures': 24},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes cours'),
        actions: [
          IconButton(
            tooltip: isDarkMode
                ? 'Activer le thème clair'
                : 'Activer le thème sombre',
            onPressed: onToggleTheme,
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Modules du semestre',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                final name = module['nom']! as String;
                final teacher = module['enseignant']! as String;
                final hours = module['heures']! as int;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 16,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text('$teacher · $hours h'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      final messenger = ScaffoldMessenger.of(context);
                      messenger.removeCurrentSnackBar();
                      messenger.showSnackBar(
                        SnackBar(content: Text('Module sélectionné : $name')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
