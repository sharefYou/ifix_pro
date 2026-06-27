import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/cache_helper.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../manager/profile_cubit.dart';
import '../../manager/profile_states.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color backgroundColor = Color(0xFFFAF5EE);
  static const Color tertiaryColor = Color(0xFF8C3C3C);
  static const Color borderColor = Color(0xFFD8D0C8);
  static const Color textColor = Color(0xFF3A302A);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: const Text('حسابي والملف الشخصي', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocBuilder<ProfileCubit, ProfileStates>(
          builder: (context, state) {
            final cubit = context.read<ProfileCubit>();
            if (state is ProfileLoadingState) {
              return const Center(child: CircularProgressIndicator(color: tertiaryColor));
            } else if (state is ProfileErrorState && cubit.currentUser == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error, style: const TextStyle(color: textColor)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: tertiaryColor),
                      onPressed: () => cubit.fetchProfile(),
                      child: const Text('إعادة المحاولة', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            final user = cubit.currentUser;
            if (user == null) {
              return const Center(child: Text('جاري تحميل الملف الشخصي...', style: TextStyle(color: textColor)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: tertiaryColor.withValues(alpha: 0.1),
                        backgroundImage: user.avatar != null ? NetworkImage(user.avatar!) : null,
                        child: user.avatar == null ? const Icon(Icons.person, size: 50, color: tertiaryColor) : null,
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: tertiaryColor, shape: BoxShape.circle),
                        child: InkWell(
                          onTap: () => context.push(EditProfileScreen(user: user)),
                          child: const Icon(Icons.edit, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 32),
                  _buildProfileCard(
                    context,
                    title: 'تعديل البيانات الشخصية',
                    icon: Icons.person_outline,
                    onTap: () => context.push(EditProfileScreen(user: user)),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    context,
                    title: 'العناوين المحفوظة',
                    icon: Icons.location_on_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    context,
                    title: 'مركز المساعدة والدعم',
                    icon: Icons.help_outline,
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildProfileCard(
                    context,
                    title: 'الشروط والأحكام والخصوصية',
                    icon: Icons.privacy_tip_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        await CacheHelper.deleteData(key: 'token');
                        await CacheHelper.deleteData(key: 'user');
                        if (context.mounted) {
                          context.pushAndRemoveUntil(const LoginScreen(), (route) => false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: tertiaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: tertiaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
