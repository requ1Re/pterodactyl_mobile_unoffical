import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool showApiKeyError = false;

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        showApiKeyError = prefs.getString("pterodactyl_apikey") == null || prefs.getString("pterodactyl_apikey") == "";
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 50),
                child: Text("Home", style: TextStyle(fontSize: 38)),
              ),
              Visibility(
                visible: showApiKeyError,
                child: CustomCard(
                  child: ListTile(
                      title: Text("No API Key found. Please set your Pterodactyl API Key in the settings.", style: TextStyle(color: Colors.white)),
                      leading: FaIcon(FontAwesomeIcons.info, color: Colors.white)
                  ),
                  backgroundColor: Colors.redAccent,
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}
