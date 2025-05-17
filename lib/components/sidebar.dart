import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          right: BorderSide(
            color: Colors.grey[800]!,
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: _buildShadcnButton(
              icon: const Icon(Icons.home, color: Colors.white),
              text: 'Home',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: _buildShadcnButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              text: 'Settings',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/settings');
              },
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[800]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.download, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Downloads',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'MonaSans',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadcnButton({
    required Widget icon,
    required String text,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 200,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: Colors.grey[800]!, width: 1),
          ),
        ),
        onPressed: onPressed,
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
      ),
    );
  }
}
