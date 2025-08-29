import 'package:flutter/material.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
    );
  }
}
