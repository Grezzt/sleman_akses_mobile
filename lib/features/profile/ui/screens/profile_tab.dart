import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/system_response_dialog.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../logic/profile_controller.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ProfileController>().fetchStats();
      }
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthController, ProfileController>(
      builder: (context, auth, profile, _) {
        final user = auth.user;
        final initials = user != null ? _getInitials(user.fullName) : 'U';

        final totalDikirim = profile.totalDikirim;
        final totalDisetujui = profile.totalDisetujui;
        final totalDitolak = profile.totalDitolak;

        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 40, bottom: 80),
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfileScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC7DE64), // Lime green
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user?.fullName ?? 'Memuat...',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.border,
                              blurRadius: 0,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              totalDikirim.toString(),
                              'Laporan Dikirim',
                              AppTheme.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _buildStatItem(
                              totalDisetujui.toString(),
                              'Disetujui',
                              AppTheme.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[200],
                            ),
                            _buildStatItem(
                              totalDitolak.toString(),
                              'Ditolak',
                              AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                if (profile.statsErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      profile.statsErrorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profil',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Ubah Kata Sandi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.notifications_none,
                          title: 'Pengaturan Notifikasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SystemResponseDialog.success(
                                title: 'Segera Hadir!',
                                description:
                                    'Fitur Pengaturan Notifikasi sedang dalam tahap pengembangan.',
                                imagePath: 'public/maskot-genit.svg',
                                buttonText: 'Tutup',
                                onButtonPressed: () => Navigator.pop(context),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.info_outline,
                          title: 'Tentang Aplikasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SystemResponseDialog.success(
                                title: 'Segera Hadir!',
                                description:
                                    'Fitur Tentang Aplikasi sedang dalam tahap pengembangan.',
                                imagePath: 'public/maskot-genit.svg',
                                buttonText: 'Tutup',
                                onButtonPressed: () => Navigator.pop(context),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 64),
                        _buildProfileMenuItem(
                          icon: Icons.shield_outlined,
                          title: 'Kebijakan Privasi',
                          iconBgColor: AppTheme.primary.withOpacity(0.1),
                          iconColor: AppTheme.primary,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => SystemResponseDialog.success(
                                title: 'Segera Hadir!',
                                description:
                                    'Fitur Kebijakan Privasi sedang dalam tahap pengembangan.',
                                imagePath: 'public/maskot-genit.svg',
                                buttonText: 'Tutup',
                                onButtonPressed: () => Navigator.pop(context),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthController>().logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
