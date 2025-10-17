import "package:flutter/material.dart";
import "../theme.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          "Business details, VAT %, tax bands, bank links, invoice template",
          style: TextStyle(color: ForemanColors.white),
        ),
      ],
    );
  }
}
