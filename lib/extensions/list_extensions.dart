extension ListExtensions<T> on List<T> {
  List<T> alphabetically() {
    List<T> elements = this.toList();
    elements.sort((a, b) {
      return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
    });
    return elements;
  }
}
