import 'package:styx/styx.dart';

class CountComponent extends Component with SerializableComponent {
  CountComponent(int count) {
    this.count.add(count);
  }

  final count = 0.bs;

  @override
  void onRemoved() {
    count.close();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "count": count.value,
    };
  }
}

class NameComponent extends Component with SerializableComponent {
  NameComponent(String name) {
    this.name.add(name);
  }

  final name = ''.bs;

  @override
  void onRemoved() {
    name.close();
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "name": name.value,
    };
  }
}

class CartComponent extends Component {
  CartComponent();
}

class CatalogItemComponent extends Component {
  CatalogItemComponent();
}

class PriceComponent extends Component {
  PriceComponent(double price) {
    // Add the value.
    this.price.add(price);
  }

  final price = 0.00.bs;

  @override
  void onRemoved() {
    price.close();
  }
}
