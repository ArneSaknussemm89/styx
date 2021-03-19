import './entity.dart';

abstract class Component {
  Component();

  /// A reference to the entity containing this component.
  late Entity ref;

  T getComponent<T extends Component>() {
    return ref.get<T>();
  }

  factory Component.fromJson(Map<String, dynamic> json) => throw UnimplementedError();
}
