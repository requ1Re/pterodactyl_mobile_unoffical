import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pterodactyl_mobile/pages/servers.dart';
import 'package:pterodactyl_mobile/pages/settings.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';

void main() {
  runApp(
      EasyDynamicThemeWidget(
        child: PterodactylMobile(),
      )
  );
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _themeData;

  ThemeNotifier(this._themeData);

  getTheme() => _themeData;

  setTheme(ThemeData themeData) async {
    _themeData = themeData;
    notifyListeners();
  }
}

class PterodactylMobile extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData customDark = ThemeData.dark().copyWith(
      canvasColor: Colors.black,
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
      cardColor: Color.fromRGBO(33, 33, 33, 1),
      shadowColor: Color.fromRGBO(20, 20, 20, 1)
    );

    return MaterialApp(
      title: 'Pterodactyl App Control',
      theme: ThemeData.light(),
      darkTheme: customDark,
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: PterodactylMobileHomePage(title: 'Pterodactyl App Control'),
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
  int _page = 0;
  PageController _c;

  @override
  void initState(){
    _c =  new PageController(
      initialPage: _page,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            currentIndex: _page,
            onTap: (index){
              this._c.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
            },
            selectedItemColor: Theme.of(context).colorScheme.primary,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.server),
                label: 'Servers',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.cog),
                label: 'Settings',
              ),
            ],
        ),
      ),
      body: PageView(
        controller: _c,
        onPageChanged: (newPage) {
          setState(() {
            this._page = newPage;
            FocusScope.of(context).unfocus();
          });
        },
        children: [
          ServersPage(),
          SettingsPage()
        ],
      ),
    );
  }
}
