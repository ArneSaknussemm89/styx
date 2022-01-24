part of extensions;

extension BehaviorSubjectAddValue<T> on BehaviorSubject<T> {
  T call([T? v]) {
    if (v != null) {
      add(v);
    }

    return value;
  }
}

extension BehaviorSubjectAddNullableValue<T> on BehaviorSubject<T?> {
  T? call([T? v]) {
    add(v);
    return value;
  }
}

extension BehaviorSubjectCreator<T> on T {
  BehaviorSubject<T> get bs => BehaviorSubject<T>.seeded(this);
}

extension BehaviorSubjectBoolCreator on bool {
  BehaviorSubject<bool> get bs => BehaviorSubject<bool>.seeded(this);
}

extension BehaviorSubjectIntCreator on int {
  BehaviorSubject<int> get bs => BehaviorSubject<int>.seeded(this);
}

extension BehaviorSubjectDoubleCreator on double {
  BehaviorSubject<double> get bs => BehaviorSubject<double>.seeded(this);
}

extension BehaviorSubjectStringCreator on String {
  BehaviorSubject<String> get bs => BehaviorSubject<String>.seeded(this);
}
