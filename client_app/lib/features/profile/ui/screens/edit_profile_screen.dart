import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/helpers/extensions.dart';
import '../../data/models/user_model.dart';
import '../../manager/profile_cubit.dart';
import '../../manager/profile_states.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color backgroundColor = Color(0xFF0D1117);
  static const Color tertiaryColor = Color(0xFF2979FF);
  static const Color borderColor = Color(0xFF30363D);
  static const Color textColor = Color(0xFFF0F6FC);

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController cityController;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
    emailController = TextEditingController(text: widget.user.email ?? '');
    cityController = TextEditingController(text: widget.user.city ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    cityController.dispose();
    super.dispose();
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
          leading: const BackButton(color: textColor),
          title: const Text('تعديل البيانات', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: BlocConsumer<ProfileCubit, ProfileStates>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccessState) {
              context.showOverlaySnackBar(message: 'تم تحديث بيانات الملف الشخصي بنجاح', type: Success());
              context.pop();
            } else if (state is ProfileUpdateErrorState) {
              context.showOverlaySnackBar(message: state.error, type: Error());
            }
          },
          builder: (context, state) {
            final isLoading = state is ProfileUpdateLoadingState;
            return Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 16),
                  _buildInputLabel('الاسم الكامل'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال الاسم' : null,
                    decoration: _inputDecoration(Icons.person),
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('رقم الهاتف'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                    decoration: _inputDecoration(Icons.phone),
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('البريد الإلكتروني (اختياري)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(Icons.email),
                  ),
                  const SizedBox(height: 16),
                  _buildInputLabel('المدينة'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cityController,
                    decoration: _inputDecoration(Icons.location_city),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tertiaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                context.read<ProfileCubit>().updateProfile(
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      email: emailController.text.trim(),
                                      city: cityController.text.trim(),
                                    );
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ التعديلات', style: TextStyle(fontSize: 18, color: Color(0xFF161B22), fontWeight: FontWeight.bold)),
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

  Widget _buildInputLabel(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor));
  }

  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF161B22),
      prefixIcon: Icon(icon, color: tertiaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: tertiaryColor, width: 2)),
    );
  }
}



