import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:package_info/package_info.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> _themes = ['Light', 'Dark'];
  String _selectedTheme;

  String _appVersionText = "";

  final _pterodactylApiKeyController = TextEditingController();
  final _pterodactylUrlController = TextEditingController();

  @override
  void initState() {
    SharedPreferences.getInstance().then((prefs) {
      String apikey = prefs.getString("pterodactyl_apikey") ?? "";
      _pterodactylApiKeyController.value = TextEditingValue(
        text: apikey,
        selection: TextSelection.collapsed(offset: apikey.length),
      );

      String url = prefs.getString("pterodactyl_url") ?? "";
      _pterodactylUrlController.value = TextEditingValue(
        text: url,
        selection: TextSelection.collapsed(offset: url.length),
      );
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;

      setState(() {
        _appVersionText = appName + " v" + version + " (Build " + buildNumber + ")";
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _selectedTheme = Theme.of(context).brightness == Brightness.light ? _themes[0]: _themes[1];

    return Center(
      child: Container(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 50),
              child: Text("Settings", style: TextStyle(fontSize: 38), textAlign: TextAlign.center),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Text("Pterodactyl Settings", style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
            ),
            buildSettingCard(FontAwesomeIcons.link, "Panel URL", TextField(
              controller: _pterodactylUrlController,
              textAlign: TextAlign.right,
              onChanged: (text) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("pterodactyl_url", _pterodactylUrlController.text);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Panel URL"
              ),
            )),
            buildSettingCard(FontAwesomeIcons.key, "API Key", TextField(
              controller: _pterodactylApiKeyController,
              textAlign: TextAlign.right,
              onChanged: (text) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString("pterodactyl_apikey", _pterodactylApiKeyController.text);
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "API Key"
              ),
            )),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 10),
              child: Text("App Settings", style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
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
            Text(_appVersionText, textAlign: TextAlign.center)
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pterodactylApiKeyController.dispose();
    _pterodactylUrlController.dispose();
    super.dispose();
  }

  Widget buildSettingCard(IconData icon, String caption, Widget settingWidget){
    return CustomCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: FaIcon(icon, size: 20),
              ),
              Text(caption, style: TextStyle(fontSize: 16)),
              Expanded(child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: settingWidget,
              )),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        )
    );
  }
}
