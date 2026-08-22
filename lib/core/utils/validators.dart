class Validators {
  Validators._();
  static final _email = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,}$');

  static String? required(String? v, [String field = 'This field']) =>
      (v ?? '').trim().isEmpty ? '$field is required' : null;

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!_email.hasMatch(s)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Password is required';
    if (s.length < 6) return 'Must be at least 6 characters';
    return null;
  }

  static String? name(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Name is required';
    if (s.length < 2) return 'Name is too short';
    return null;
  }
}
