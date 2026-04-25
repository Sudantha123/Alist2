import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../app/app.dart';
import '../../../data/repositories/alist_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          _SectionHeader(label: 'Appearance'),
          
          _SettingsTile(
            icon: Iconsax.moon,
            title: 'Dark Mode',
            trailing: Switch(
              value: themeMode == ThemeMode.dark,
              activeColor: const Color(0xFF6C63FF),
              onChanged: (value) {
                ref.read(themeProvider.notifier).state =
                    value ? ThemeMode.dark : ThemeMode.light;
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account
          _SectionHeader(label: 'Account'),
          
          _SettingsTile(
            icon: Iconsax.logout,
            title: 'Logout',
            iconColor: const Color(0xFFCF6679),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCF6679),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && context.mounted) {
                await ref.read(alistRepositoryProvider).logout();
                context.go('/login');
              }
            },
          ),
          
          const SizedBox(height: 24),
          
          // About
          _SectionHeader(label: 'About'),
          
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: 'Version',
            trailing: const Text(
              '1.0.0',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF6C63FF),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF6C63FF)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: trailing ?? (onTap != null 
            ? const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54)
            : null),
        onTap: onTap,
      ),
    );
  }
}
