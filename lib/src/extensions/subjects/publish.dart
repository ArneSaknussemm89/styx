part of extensions;

extension PublishSubjectAddValue<T> on PublishSubject<T> {
  @Deprecated('Use .add instead. This was kept for backwards compatibility. Will be removed in 3.0.0')
  Stream<T> call([T? v]) {
    if (v != null) {
      add(v);
    }

    return stream;
  }
}

extension PublishSubjectAddNullableValue<T> on PublishSubject<T?> {
  @Deprecated('Use .add instead. This was kept for backwards compatibility. Will be removed in 3.0.0')
  Stream<T?> call([T? v]) {
    add(v);
    return stream;
  }
}

extension PublishSubjectCreator<T> on T {
  PublishSubject<T> get ps => PublishSubject<T>();
}

extension PublishSubjectBoolCreator on bool {
  PublishSubject<bool> get ps => PublishSubject<bool>();
}

extension PublishSubjectIntCreator on int {
  PublishSubject<int> get ps => PublishSubject<int>();
}

extension PublishSubjectDoubleCreator on double {
  PublishSubject<double> get ps => PublishSubject<double>();
}

extension PublishSubjectStringCreator on String {
  PublishSubject<String> get ps => PublishSubject<String>();
}