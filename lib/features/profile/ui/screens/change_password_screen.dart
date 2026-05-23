import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/system_response_dialog.dart';
import '../../logic/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = context.read<ProfileController>();
    final success = await controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordConfirmation: _confirmPasswordController.text,
    );

    if (mounted) {
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SystemResponseDialog.success(
            title: 'Berhasil!',
            description: 'Kata sandi berhasil diperbarui',
            buttonText: 'Tutup',
            imagePath: 'public/onboarding slide 3.svg',
            onButtonPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
          ),
        );
      } else {
        final message =
            controller.updateErrorMessage ?? 'Gagal memperbarui kata sandi';
        showDialog(
          context: context,
          builder: (context) => SystemResponseDialog.error(
            title: 'Gagal!',
            description: message,
            onButtonPressed: () => Navigator.pop(context),
          ),
        );
      }
    }
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscureText,
    VoidCallback toggleObscure,
    String? errorText, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: toggleObscure,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Ubah Kata Sandi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: Consumer<ProfileController>(
        builder: (context, profile, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (profile.updateErrorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      profile.updateErrorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                _buildPasswordField(
                  'Kata Sandi Saat Ini',
                  _currentPasswordController,
                  _obscureCurrent,
                  () => setState(() => _obscureCurrent = !_obscureCurrent),
                  profile.fieldError('current_password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi saat ini harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Kata Sandi Baru',
                  _newPasswordController,
                  _obscureNew,
                  () => setState(() => _obscureNew = !_obscureNew),
                  profile.fieldError('new_password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi baru harus diisi';
                    }
                    if (value.length < 8) {
                      return 'Kata sandi minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  'Konfirmasi Kata Sandi Baru',
                  _confirmPasswordController,
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                  profile.fieldError('new_password_confirmation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi kata sandi harus diisi';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Konfirmasi tidak cocok dengan kata sandi baru';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: profile.isUpdating ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: profile.isUpdating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Kata Sandi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
