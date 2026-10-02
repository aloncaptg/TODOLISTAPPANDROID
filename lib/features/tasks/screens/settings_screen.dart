import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final titleController = TextEditingController(text: user.title);
    String selectedAvatar = user.avatar;

    final avatars = ['👨‍💻', '👩‍💻', '🚀', '🎯', '⚡', '💡', '💼', '🏆'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: avatars.map((e) {
                    final isSel = selectedAvatar == e;
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedAvatar = e),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSel
                              ? AppTheme.primarySeed.withValues(alpha: 0.2)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSel
                                ? AppTheme.primarySeed
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Peran / Jabatan'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primarySeed),
              onPressed: () {
                authProvider.updateProfile(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  avatar: selectedAvatar,
                  title: titleController.text.trim(),
                );
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profil berhasil diperbarui!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportJson(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    final jsonStr = taskProvider.exportJson();
    Clipboard.setData(ClipboardData(text: jsonStr));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data cadangan JSON berhasil disalin ke Clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    final importController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pulihkan Data (Import JSON)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tempelkan teks data cadangan JSON yang sebelumnya Anda salin:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: importController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '{\n  "tasks": [...]\n}',
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.primarySeed),
            onPressed: () async {
              final text = importController.text.trim();
              if (text.isEmpty) return;

              final success =
                  await context.read<TaskProvider>().importJson(text);
              if (ctx.mounted) Navigator.of(ctx).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Data tugas berhasil dipulihkan!'
                        : 'Format JSON tidak valid.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _shareFormattedList(BuildContext context) {
    final text = context.read<TaskProvider>().generateFormattedShareText();
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daftar tugas tersusun rapi disalin ke Clipboard! Siap dibagikan ke WhatsApp/Email.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Kartu Profil Pengguna
          if (user != null)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primarySeed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        user.avatar,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (user.isGuest) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'GUEST',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.title,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.primarySeed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profil',
                      onPressed: () => _showEditProfileDialog(context),
                    ),
                  ],
                ),
              ),
            ),

          // Pengaturan Tema
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Tampilan Antarmuka',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Tema Aplikasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistem'),
                          icon: Icon(Icons.brightness_auto_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Terang'),
                          icon: Icon(Icons.light_mode_rounded),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Gelap'),
                          icon: Icon(Icons.dark_mode_rounded),
                        ),
                      ],
                      selected: {themeProvider.themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        themeProvider.setThemeMode(newSelection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Manajemen Data & Backup
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Manajemen Data & Backup',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_rounded,
                      color: AppTheme.primarySeed),
                  title: const Text('Export Data (Salin JSON)'),
                  subtitle: const Text(
                      'Cadangkan seluruh data tugas ke format JSON di Clipboard.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _exportJson(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_rounded,
                      color: AppTheme.accentCyan),
                  title: const Text('Import Data (Pulihkan JSON)'),
                  subtitle: const Text(
                      'Pulihkan daftar tugas dari teks JSON cadangan.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showImportDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.share_rounded,
                      color: AppTheme.statusDone),
                  title: const Text('Bagikan Daftar Tugas'),
                  subtitle: const Text(
                      'Salin format rapi untuk WhatsApp atau Catatan.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _shareFormattedList(context),
                ),
              ],
            ),
          ),

          // Informasi Aplikasi
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Tentang Aplikasi',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('Versi Aplikasi'),
                  trailing: Text(
                    AppConstants.appVersion,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.storage_rounded),
                  title: Text('Database Engine'),
                  trailing: Text(
                    'SQLite + SharedPreferences',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Logout
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar dari Akun?'),
                  content: const Text(
                      'Anda akan diarahkan kembali ke halaman login. Data tugas lokal Anda tetap tersimpan aman di perangkat.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.priorityUrgent),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout_rounded,
                color: AppTheme.priorityUrgent),
            label: const Text(
              'Ganti Akun / Keluar',
              style: TextStyle(color: AppTheme.priorityUrgent),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.priorityUrgent),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
