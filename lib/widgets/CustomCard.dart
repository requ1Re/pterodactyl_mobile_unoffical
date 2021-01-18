import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({ Key key, this.child, this.backgroundColor }) : super(key: key);

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = backgroundColor;
    if(_backgroundColor == null) _backgroundColor = Theme.of(context).cardColor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.25),
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: child,
      ),
    );
  }
}
