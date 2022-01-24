import './entity.dart';

abstract class Component {
  Component();

  /// A reference to the entity containing this component.
  late Entity ref;

  T getComponent<T extends Component>() {
    return ref.get<T>();
  }

  // Called when the component is added.
  void onAdded() {}

  // Called when the component is removed.
  void onRemoved() {}

  factory Component.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}
