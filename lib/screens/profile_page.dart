import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: CircleAvatar(
                        radius: 45,
                        child: ClipOval(
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: Image.asset(
                              'assets/images/profil.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: _buildProfileImageFallback,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildStudentCard(),
              const SizedBox(height: 24),
              const Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildInformation(Icons.person, 'Nom', 'Aymen Nafis'),
              const SizedBox(height: 12),
              _buildInformation(Icons.school, 'Filière', 'Informatique'),
              const SizedBox(height: 12),
              _buildInformation(Icons.class_, 'Niveau', 'S5'),
              const SizedBox(height: 12),
              _buildInformation(Icons.email, 'Email', 'Aymen@gmail.com'),
              const SizedBox(height: 12),
              _buildInformation(
                Icons.calendar_month,
                'Année universitaire',
                '2026–2027',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        debugPrint('Modification du profil demandée');
                      },
                      child: const Text(
                        'Modifier le profil',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        debugPrint('Contact demandé');
                      },
                      child: const Text('Contacter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      key: const ValueKey('student-card'),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.account_balance,
              size: 96,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: SizedBox(
                      width: 68,
                      height: 68,
                      child: Image.asset(
                        'assets/images/profil.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: _buildProfileImageFallback,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'EMSI',
                              style: TextStyle(
                                color: Colors.blue.shade50,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Aymen Nafis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Informatique · S5',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'N° étudiant : EMSI-2026-0042',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildProfileImageFallback(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    debugPrint('Impossible de charger assets/images/profil.jpg: $error');
    return const Icon(Icons.person, size: 48);
  }

  Widget _buildInformation(IconData icon, String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text('$label : $value')),
        ],
      ),
    );
  }
}
