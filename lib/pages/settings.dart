import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

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
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Text("Settings", style: TextStyle(fontSize: 32)),
              ),
              buildSettingCard("API Key", TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "API Key"
                ),
              )),
              buildSettingCard("App Theme", DropdownButton(
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
              ),)
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSettingCard(String caption, Widget settingWidget){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10.0),
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
        child: Row(
          children: [
            Expanded(child: Text(caption, style: TextStyle(fontSize: 18))),
            Expanded(child: settingWidget),
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }


}
