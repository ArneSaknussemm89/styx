import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// GetX helpers
extension GetXHelpersRx<T> on Rx<T> {
  Widget styx(Widget Function(T data) builder) {
    return Obx(() {
      return builder(value);
    });
  }

  Widget styxn(Widget Function(T? data) builder) {
    return Obx(() {
      return builder(value);
    });
  }
}

/// Helper extension on RxObjectMixins to make re-rendering widgets easy with
/// no boilerplate needed. For example:
///
/// Take this model Post:
/// class Post {
///   Post({String title, int id}) {
///     this.title(title);
///     this.id(id);
///   }
///
///   final id = 0.obs;
///   final title = ''.obs;
/// }
///
/// Then, with this model, you can easily view it by doing something like:
///
/// class ViewPost extends StatelessWidget {
///   const ViewPost({this.post});
///
///   final Post post;
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         post.title.styx((value) {
///           return Text(value);
///         }),
///         post.id.styx((value) {
///           return Padding(
///             padding: const EdgeInsets.only(top: 10),
///             child: Text(value.toString()),
///           );
///         }),
///       ],
///     );
///   }
/// }
extension GetXHelpersRxMixin<T> on RxObjectMixin<T> {
  Widget styx(Widget Function(T data) builder) {
    return Obx(() {
      return builder(this.value);
    });
  }

  Widget styxn(Widget Function(T? data) builder) {
    return Obx(() {
      return builder(this.value);
    });
  }
}
