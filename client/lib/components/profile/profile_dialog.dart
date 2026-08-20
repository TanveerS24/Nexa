import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/supabase/auth_service.dart';

class ProfileDialog extends StatefulWidget {
  final VoidCallback onSignOut;

  const ProfileDialog({super.key, required this.onSignOut});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  double? _height;
  double? _weight;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _height = AuthService.getUserHeight();
    _weight = AuthService.getUserWeight();
  }

  Future<void> _showEditStatsDialog() async {
    final heightCtrl = TextEditingController(text: _height?.toString() ?? '');
    final weightCtrl = TextEditingController(text: _weight?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update Body Stats',
                style: AppTextStyles.promptTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  hintText: 'e.g. 175',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  hintText: 'e.g. 70.5',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final newHeight = double.tryParse(heightCtrl.text.trim());
                      final newWeight = double.tryParse(weightCtrl.text.trim());
                      Navigator.of(ctx).pop();

                      setState(() => _isSaving = true);
                      await AuthService.updateProfile(
                        height: newHeight,
                        weight: newWeight,
                      );
                      if (mounted) {
                        setState(() {
                          _height = newHeight;
                          _weight = newWeight;
                          _isSaving = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ambientWarmGlow,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = AuthService.getUserDisplayName();
    final email = user?.email ?? 'Not signed in';
    final dob = AuthService.getUserDob();
    final age = AuthService.getUserAge();
    final isBirthday = AuthService.isUserBirthdayToday();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isBirthday ? const Color(0xFF5A3C28) : AppColors.navActivePill,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isBirthday ? AppColors.ambientWarmGlow : AppColors.navActiveIcon,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: isBirthday ? AppColors.ambientWarmGlow : AppColors.navActiveIcon,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                displayName,
                style: AppTextStyles.brandTitle.copyWith(fontSize: 20),
              ),

              const SizedBox(height: 4),

              Text(
                email,
                style: AppTextStyles.greetingSubtitle,
              ),

              if (isBirthday) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.ambientWarmGlow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ambientWarmGlow),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎂', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 6),
                      Text(
                        "It's your birthday today! 🎉",
                        style: TextStyle(
                          color: AppColors.ambientWarmGlow,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Personal Stats Card (DOB & Age)
              if (dob != null || age != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      if (dob != null)
                        Column(
                          children: [
                            const Text('Date of Birth',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              "${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      if (age != null)
                        Column(
                          children: [
                            const Text('Age',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              '$age years old',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 10),

              // Optional Body Stats Card (Height & Weight)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Height',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              _height != null ? '${_height!.toStringAsFixed(0)} cm' : 'Not set',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Weight',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(
                              _weight != null ? '${_weight!.toStringAsFixed(1)} kg' : 'Not set',
                              style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _isSaving ? null : _showEditStatsDialog,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              color: AppColors.ambientWarmGlow.withValues(alpha: 0.9),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _height == null && _weight == null
                                  ? 'Add Height & Weight'
                                  : 'Edit Height & Weight',
                              style: const TextStyle(
                                color: AppColors.ambientWarmGlow,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Divider(color: AppColors.exploreBorder),

              const SizedBox(height: 14),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await AuthService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      widget.onSignOut();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFFF8B8B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Close Button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
