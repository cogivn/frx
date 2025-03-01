extension StringX on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  String uncapitalize() {
    if (isEmpty) return this;
    return this[0].toLowerCase() + substring(1);
  }
}
