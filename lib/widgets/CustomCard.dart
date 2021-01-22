import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({ Key key, this.child, this.backgroundColor, this.onTap }) : super(key: key);

  final Widget child;
  final Color backgroundColor;
  final void Function() onTap;


  @override
  Widget build(BuildContext context) {
    Color _backgroundColor = backgroundColor;
    if(_backgroundColor == null) _backgroundColor = Theme.of(context).cardColor;

    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.25),
            spreadRadius: 3,
            blurRadius: 6,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: child,
        ),
      ),
    );
  }
}
