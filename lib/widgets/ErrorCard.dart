import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({ Key key, this.errorTitle = "An Error occurred:", this.errorText }) : super(key: key);

  final String errorTitle;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(20.0),
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
        child: ListTile(
          title: Text(errorTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(errorText, style: TextStyle(color: Colors.white)),
          leading: FaIcon(FontAwesomeIcons.exclamationTriangle, color: Colors.white)
        ),
      ),
    );
  }
}
