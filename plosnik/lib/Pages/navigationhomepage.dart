import 'package:flutter/material.dart';
import 'entrypage.dart';

class NavigationHomePage extends StatefulWidget {
  const NavigationHomePage({super.key});

  @override
  State<NavigationHomePage> createState() => _NavigationHomePageState();
}

class _NavigationHomePageState extends State<NavigationHomePage> {
  int _selectedIndex = 0; // Keeps track of selected page index

  final List<Widget> _pages = [
    const EntryPage(),
    const PlaceholderPage('Weekly Graph Page'),
    const PlaceholderPage('Monthly Graph Page'),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_selectedIndex) {
  case 0:
    page = _pages[0];
    break;
  case 1:
    page = _pages[1];
    break;
  case 2:
    page = _pages[2];
    break;
  default:
    throw UnimplementedError('no widget for $_selectedIndex');
}
        return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.edit),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.show_chart),
                      label: Text('Weekly Chart'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calendar_month),
                      label: Text('Monthly Chart'),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}