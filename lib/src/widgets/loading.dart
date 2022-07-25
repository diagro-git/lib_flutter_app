import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget
{
  final double size;
  final String? text;
  final Color color;
  final Widget? loadingAnimationWidget;

  const Loading({this.size = 48, this.color = Colors.lightBlueAccent, this.text, this.loadingAnimationWidget, Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = LoadingAnimationWidget.beat(color: Colors.lightBlueAccent, size: 48);
    if(loadingAnimationWidget != null) {
      loadingWidget = loadingAnimationWidget!;
    }

    return Center(
        child: Column
          (children:
        [loadingWidget,
          if(text != null)
          Padding(child: Text(text!), padding: const EdgeInsets.only(top: 15))],
            mainAxisAlignment: MainAxisAlignment.center));
  }

}