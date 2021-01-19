import 'dart:ui';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:pterodactyl_mobile/one_ui_scroll_view/one_ui_scroll_view.dart';
import 'package:pterodactyl_mobile/widgets/CustomCard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> _themes = ['Light', 'Dark', 'System'];
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
    ThemeMode themeMode = EasyDynamicTheme.of(context).themeMode;
    switch(themeMode){
      case ThemeMode.light:
        _selectedTheme = "Light";
        break;

      case ThemeMode.dark:
        _selectedTheme = "Dark";
        break;

      case ThemeMode.system:
        _selectedTheme = "System";
        break;
    }

    return Center(
      child: OneUiScrollView(
        expandedHeight: 200,
        bottomDivider: Divider(
          color: Theme.of(context).shadowColor,
          indent: 0,
          endIndent: 0,
          height: 1,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        expandedTitle: Text('Settings', style: TextStyle(fontSize: 32)),
        collapsedTitle: Text('Settings', style: TextStyle(fontSize: 24)),
        childrenPadding: EdgeInsets.all(10),
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10),
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
          Text(_appVersionText, textAlign: TextAlign.center),
          buildSettingCard(FontAwesomeIcons.solidSun, "Theme", DropdownButton(
            isExpanded: true,
            hint: Text('Theme'),
            value: _selectedTheme,
            onChanged: (newValue) {
              setState(() {
                _selectedTheme = newValue;
              });
              if(newValue == _themes[0]){
                EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: false);
              }else if(newValue == _themes[1]){
                EasyDynamicTheme.of(context).changeTheme(dynamic: false, dark: true);
              }else if(newValue == _themes[2]){
                EasyDynamicTheme.of(context).changeTheme(dynamic: true);
              }
            },
            items: _themes.map((location) {
              return DropdownMenuItem(
                child: new Text(location),
                value: location,
              );
            }).toList(),
          )),
          Container(
            margin: EdgeInsets.only(top: 30, bottom: 10),
            child: Text("3rd-Party Libraries", style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
          ),
          Text("one_ui_scroll_view by Minseong Kim (jja08111 on GitHub)", textAlign: TextAlign.center, maxLines: 2),
        ],
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