import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stresspredictor/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:stresspredictor/core/theme/app_colors.dart';
import 'package:stresspredictor/providers/auth_provider.dart';
import 'package:stresspredictor/providers/profile_provider.dart';
import 'package:stresspredictor/providers/stress_provider.dart';

/// Profile screen – editable user info, notification toggle,
/// stress history stats, and functional logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer2<ProfileProvider, StressProvider>(
        builder: (context, profileProv, stressProv, _) {
          final profile = profileProv.profile;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(context, profileProv),
                const Divider(height: 32),
                _buildStressStats(stressProv),
                const SizedBox(height: 8),
                const Divider(height: 1),
                _buildSettingsSection(context, profile.notificationsEnabled,
                    profileProv, stressProv),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── User info ─────────────────────────────────────────────────────────────

  Widget _buildUserInfo(BuildContext context, ProfileProvider prov) {
    // The profile provider still manages notifications & memberSince locally.
    // AuthProvider manages the actual logged-in user identity.
    final authUser = context.watch<AuthProvider>().currentUser;
    final fallbackProfile = prov.profile;

    final name = authUser?.name ?? fallbackProfile.name;
    final email = authUser?.email ?? fallbackProfile.email;
    final joined = authUser?.createdAt ?? fallbackProfile.memberSince;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.person, size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        fontSize: 14, )),
                const SizedBox(height: 4),
                Text(
                  'Member since ${_formatDate(joined)}',
                  style: const TextStyle(
                      fontSize: 12, ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
            onPressed: () => _showEditDialog(context, prov),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ProfileProvider prov) {
    final nameCtrl =
        TextEditingController(text: prov.profile.name);
    final emailCtrl =
        TextEditingController(text: prov.profile.email);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await prov.updateProfile(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Stress statistics ─────────────────────────────────────────────────────

  Widget _buildStressStats(StressProvider prov) {
    final history = prov.history;
    final count = history.length;

    // Average stress level
    final avg = count == 0
        ? '—'
        : (history.map((p) => p.stressLevel).reduce((a, b) => a + b) / count)
            .toStringAsFixed(1);

    // Weekly count (last 7 days)
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekCount =
        history.where((p) => p.timestamp.isAfter(weekAgo)).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stress History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard('Average', avg, AppColors.stressLow),
              const SizedBox(width: 12),
              _statCard('This Week', '$weekCount', AppColors.primary),
              const SizedBox(width: 12),
              _statCard('Total', '$count', AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, )),
          ],
        ),
      ),
    );
  }

  // ── Settings section ──────────────────────────────────────────────────────

  Widget _buildSettingsSection(
    BuildContext context,
    bool notificationsEnabled,
    ProfileProvider prov,
    StressProvider stressProv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              
            ),
          ),
        ),
        // Notification toggle
        ListTile(
          leading: _settingsIcon(Icons.notifications_outlined),
          title: const Text('Notifications',
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: const Text('Daily stress reminders',
              style: TextStyle(fontSize: 12, )),
          trailing: Switch(
            value: notificationsEnabled,
            activeThumbColor: AppColors.primary,
            onChanged: (_) => prov.toggleNotifications(),
          ),
        ),
        _settingsTile(
          icon: Icons.palette_outlined,
          title: 'Appearance',
          subtitle: 'Theme and display options',
          trailing: const Icon(Icons.chevron_right, ),
          onTap: () => context.push(AppConstants.appearancePath),
        ),
        _settingsTile(
          icon: Icons.lock_outline,
          title: 'Privacy',
          subtitle: 'Data and privacy settings',
          trailing: const Icon(Icons.chevron_right, ),
          onTap: () => context.push(AppConstants.privacyPath),
        ),
        _settingsTile(
          icon: Icons.delete_outline,
          title: 'Clear History',
          subtitle: 'Delete all stress predictions',
          trailing: const Icon(Icons.chevron_right, color: AppColors.error),
          onTap: () => _showClearHistoryDialog(context, stressProv),
        ),
        _settingsTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'FAQs and contact support',
          trailing: const Icon(Icons.chevron_right, ),
          onTap: () => context.push(AppConstants.helpPath),
        ),
      ],
    );
  }

  Widget _settingsIcon(IconData icon) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      );

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _settingsIcon(icon),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w500, )),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, )),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Log Out',
              style: TextStyle(fontWeight: FontWeight.w500)),
          onPressed: () => _showLogoutDialog(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
            },
            child: const Text('Log Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, StressProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('This will delete all saved stress predictions. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await prov.clearPredictionHistory();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('History cleared'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────


  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}