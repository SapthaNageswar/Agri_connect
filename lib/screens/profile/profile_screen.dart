// screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriconnect/providers/auth_provider.dart' as local_auth;
import 'package:agriconnect/utils/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsOn = true;
  String _language = 'English';
  final _languages = ['English', 'हिंदी', 'தமிழ்', 'తెలుగు', 'ಕನ್ನಡ', 'বাংলা'];

  Future<void> _saveLanguage(String lang) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'language': lang});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<local_auth.AuthProvider>().user;
    final initials = (user?.name ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? '—',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        Text(
                            '${user?.role == 'farmer' ? 'Farmer' : 'Buyer'} · ${user?.city.isEmpty == true ? 'India' : '${user?.city}, ${user?.state}'}',
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.textSecondary)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('✓ Verified',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Account settings
          _SectionCard(title: 'Account', items: [
            _SettingItem(
              icon: Icons.person_outline,
              iconBg: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              label: 'Full name',
              value: user?.name ?? '—',
              onTap: () => _editField(context, 'name', user?.name ?? ''),
            ),
            _SettingItem(
              icon: Icons.phone_android,
              iconBg: const Color(0xFFDBEAFE),
              iconColor: const Color(0xFF1D4ED8),
              label: 'Mobile number',
              value: user?.mobile ?? '—',
            ),
            _SettingItem(
              icon: Icons.location_city_outlined,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              label: 'City',
              value: user?.city.isEmpty == true ? 'Not set' : user!.city,
              onTap: () => _editField(context, 'city', user?.city ?? ''),
            ),
            _SettingItem(
              icon: Icons.map_outlined,
              iconBg: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              label: 'State',
              value: user?.state.isEmpty == true ? 'Not set' : user!.state,
              onTap: () => _editField(context, 'state', user?.state ?? ''),
            ),
            _SettingItem(
              icon: Icons.location_on_outlined,
              iconBg: const Color(0xFFFFEDD5),
              iconColor: const Color(0xFFEA580C),
              label: 'Detailed Location',
              value: user?.location.isEmpty == true ? 'Not set' : user!.location,
              onTap: () => _editField(context, 'location', user?.location ?? ''),
            ),
            _SettingItem(
              icon: Icons.language,
              iconBg: const Color(0xFFFCE7F3),
              iconColor: const Color(0xFFDB2777),
              label: 'Language',
              value: _language,
              onTap: () => _showLanguagePicker(context),
            ),
          ]),
          const SizedBox(height: 14),

          // Preferences
          _SectionCard(title: 'Preferences', items: [
            _SettingItem(
              icon: Icons.notifications_outlined,
              iconBg: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF475569),
              label: 'Price alerts',
              value: _notificationsOn ? 'On' : 'Off',
              trailing: Switch(
                value: _notificationsOn,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _notificationsOn = v),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // Danger zone
          _SectionCard(title: 'Account', items: [
            _SettingItem(
              icon: Icons.logout,
              iconBg: const Color(0xFFFEE2E2),
              iconColor: AppTheme.error,
              label: 'Log out',
              labelColor: AppTheme.error,
              onTap: () => _confirmLogout(context),
            ),
          ]),
          const SizedBox(height: 20),
          Center(
            child: Text('AgriConnect v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey[400])),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _editField(BuildContext context, String field, String current) {
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Edit ${field[0].toUpperCase()}${field.substring(1)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(controller: ctrl,
              decoration: InputDecoration(hintText: 'Enter $field')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .update({field: ctrl.text.trim()});
                if (context.mounted) {
                  await context.read<local_auth.AuthProvider>().updateProfile();
                }
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ]),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Language',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._languages.map((lang) => ListTile(
                  title: Text(lang),
                  trailing: _language == lang
                      ? const Icon(Icons.check, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _language = lang);
                    _saveLanguage(lang);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of AgriConnect?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(dialogContext); // Pops the dialog perfectly
              await context.read<local_auth.AuthProvider>().logout();
              // GoRouter's redirect will automatically handle going to /login
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SectionCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          children: List.generate(items.length, (i) => Column(
            children: [
              items[i],
              if (i < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          )),
        ),
      );
}

// ── Setting row ───────────────────────────────────────────────────────────
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? value;
  final Color? labelColor;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.value,
    this.labelColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration:
              BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        title: Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: labelColor ?? AppTheme.textPrimary)),
        trailing: trailing ??
            (value != null
                ? Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(value!,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                    const SizedBox(width: 4),
                    if (onTap != null)
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textHint, size: 20),
                  ])
                : null),
      );
}
