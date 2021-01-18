import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> _themes = ['Light', 'Dark'];
  String _selectedTheme;

  @override
  Widget build(BuildContext context) {
    _selectedTheme = Theme.of(context).brightness == Brightness.light ? _themes[0]: _themes[1];

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 50),
                child: Text("Settings", style: TextStyle(fontSize: 38)),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text("App Settings", style: TextStyle(fontSize: 24)),
              ),
              buildSettingCard(DynamicTheme.of(context).brightness == Brightness.light ? FontAwesomeIcons.solidSun : FontAwesomeIcons.solidMoon, "Theme", DropdownButton(
                isExpanded: true,
                hint: Text('Theme'),
                value: _selectedTheme,
                onChanged: (newValue) {
                  setState(() {
                    _selectedTheme = newValue;
                    if(newValue == _themes[0]){
                      DynamicTheme.of(context).setBrightness(Brightness.light);
                    }else if(newValue == _themes[1]){
                      DynamicTheme.of(context).setBrightness(Brightness.dark);
                    }
                  });
                },
                items: _themes.map((location) {
                  return DropdownMenuItem(
                    child: new Text(location),
                    value: location,
                  );
                }).toList(),
              )),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text("Pterodactyl Settings", style: TextStyle(fontSize: 24)),
              ),
              buildSettingCard(FontAwesomeIcons.key, "API Key", TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "API Key"
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingCard(IconData icon, String caption, Widget settingWidget){
    return CustomCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: FaIcon(icon, size: 20),
              ),
              Expanded(child: Text(caption, style: TextStyle(fontSize: 18))),
              Expanded(child: settingWidget),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        )
    );
  }
}
