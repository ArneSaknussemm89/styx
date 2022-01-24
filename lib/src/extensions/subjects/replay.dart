part of extensions;

extension ReplaySubjectAddValue<T> on ReplaySubject<T> {
  List<T> call([T? v]) {
    if (v != null) {
      add(v);
    }

    return values;
  }
}

extension ReplaySubjectAddNullableValue<T> on ReplaySubject<T?> {
  List<T?> call([T? v]) {
    add(v);
    return values;
  }
}

extension ReplaySubjectCreator<T> on T {
  ReplaySubject<T> rs(int? maxSize) => ReplaySubject<T>(maxSize: maxSize);
}

extension ReplaySubjectBoolCreator on bool {
  ReplaySubject<bool> rs(int? maxSize) => ReplaySubject<bool>(maxSize: maxSize);
}

extension ReplaySubjectIntCreator on int {
  ReplaySubject<int> rs(int? maxSize) => ReplaySubject<int>(maxSize: maxSize);
}

extension ReplaySubjectDoubleCreator on double {
  ReplaySubject<double> rs(int? maxSize) => ReplaySubject<double>(maxSize: maxSize);
}

extension ReplaySubjectStringCreator on String {
  ReplaySubject<String> rs(int? maxSize) => ReplaySubject<String>(maxSize: maxSize);
}
