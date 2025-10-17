import "package:flutter/material.dart";
import "../theme.dart";
import "settings_screen.dart";
import "jobs_screen.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Business details, VAT %, bank links, invoice template",
          style: TextStyle(color: ForemanColors.white),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            title: const Text("Settings"),
            subtitle: const Text("VAT rate, Tax reserve"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ),
        Card(
          child: ListTile(
            title: const Text("Jobs"),
            subtitle: const Text("Group invoices & receipts"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const JobsScreen())),
          ),
        ),
      ],
    );
  }
}
