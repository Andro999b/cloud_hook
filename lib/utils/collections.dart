extension SetToggle<T> on Set<T> {
  Set<T> toggle(T value) {
    if (contains(value)) {
      return where((v) => v != value).toSet();
    } else {
      return {...this, value};
    }
  }
}
