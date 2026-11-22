import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _compactMode = false;
  bool _showAdditionalInfo = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Préférences',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Autoriser les notifications'),
              secondary: const Icon(Icons.notifications_outlined),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Mode compact'),
              subtitle: const Text('Réduire certains espacements'),
              secondary: const Icon(Icons.view_compact_outlined),
              value: _compactMode,
              onChanged: (value) {
                setState(() => _compactMode = value);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Afficher les informations complémentaires'),
              secondary: const Icon(Icons.info_outline),
              value: _showAdditionalInfo,
              onChanged: (value) {
                setState(() => _showAdditionalInfo = value);
              },
            ),
            if (_showAdditionalInfo) ...[
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Ces préférences sont conservées localement tant que cette '
                  'page reste active.',
                ),
              ),
            ],
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: EdgeInsets.all(_compactMode ? 8 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'État des paramètres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Notifications : '
                      '${_notificationsEnabled ? "Activées" : "Désactivées"}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mode compact : '
                      '${_compactMode ? "Activé" : "Désactivé"}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Paramètres modifiés localement'),
                  ),
                );
              },
              child: const Text('Afficher une confirmation'),
            ),
          ],
        ),
      ),
    );
  }
}
