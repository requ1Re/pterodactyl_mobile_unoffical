import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:pterodactyl_mobile/pages/servers.dart';
import 'package:pterodactyl_mobile/pages/settings.dart';

void main() {
  runApp(PterodactylMobile());
}

class PterodactylMobile extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new DynamicTheme(
        defaultBrightness: Brightness.dark,
        data: (brightness) => new ThemeData(
          brightness: brightness,
        ),
        themedWidgetBuilder: (context, theme) {
          return new MaterialApp(
            title: 'Pterodactyl App Control',
            theme: theme,
            home: PterodactylMobileHomePage(title: 'Pterodactyl App Control'),
          );
        }
    );
  }
}

class PterodactylMobileHomePage extends StatefulWidget {
  PterodactylMobileHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _PterodactylMobileHomePageState createState() => _PterodactylMobileHomePageState();
}

class _PterodactylMobileHomePageState extends State<PterodactylMobileHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    Text('1'),
    ServersPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.25),
              spreadRadius: 3,
              blurRadius: 6,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.server),
              label: 'Servers',
            ),
            BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.cog),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
