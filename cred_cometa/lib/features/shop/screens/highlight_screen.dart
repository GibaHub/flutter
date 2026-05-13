import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HighlightScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const HighlightScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Lista de produtos em breve...",
              style: GoogleFonts.lato(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
