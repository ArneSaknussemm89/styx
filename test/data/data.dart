import 'package:get/get.dart';
import 'package:styx/styx.dart';

class CountComponent extends Component with SerializableComponent {
  CountComponent(int count) {
    this.count(count);
  }

  final count = RxInt(0);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "count": count(),
    };
  }
}

class NameComponent extends Component with SerializableComponent {
  NameComponent(String name) {
    this.name(name);
  }

  final name = ''.obs;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "name": name(),
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
    this.price(price);
  }

  final price = 0.00.obs;
}
