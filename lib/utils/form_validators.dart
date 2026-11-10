String? validateEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return 'Email obligatoire';
  if (!email.contains('@')) return 'Email invalide';
  return null;
}
