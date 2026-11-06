class Validators {
  const Validators._();

  static String? requiredText(String? value, String label) {
    return value == null || value.trim().isEmpty ? 'Nhập $label' : null;
  }

  static String? email(String? value) {
    return value == null || !value.contains('@')
        ? 'Email không hợp lệ'
        : null;
  }
}
