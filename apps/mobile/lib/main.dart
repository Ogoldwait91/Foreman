import "package:flutter/material.dart";
import "src/theme.dart";
import "src/screens/home_screen.dart";
import "src/screens/invoices_screen.dart";
import "src/screens/payments_screen.dart";
import "src/screens/profile_screen.dart";
import "src/data/app_store.dart";

void main() => runApp(const ForemanApp());

class ForemanApp extends StatefulWidget {
  const ForemanApp({super.key});
  @override
  State<ForemanApp> createState() => _ForemanAppState();
}

class _ForemanAppState extends State<ForemanApp> {
  int _index = 0;
  final store = AppStore();

  final _pages = const [
    HomeScreen(),
    InvoicesScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    store.seedIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: "Foreman",
          debugShowCheckedModeBanner: false,
          theme: ForemanTheme.dark,
          home: Scaffold(
            backgroundColor: ForemanColors.navy,
            body: SafeArea(child: _pages[_index]),
            bottomNavigationBar: NavigationBar(
              backgroundColor: ForemanColors.navy,
              indicatorColor: ForemanColors.teal.withValues(alpha: 0.15),
              selectedIndex: _index,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: "Balance"),
                NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: "Invoices"),
                NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: "Payments"),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: "Profile"),
              ],
            ),
          ),
        );
      },
    );
  }
}
