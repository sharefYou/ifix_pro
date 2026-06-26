import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ifix_tech/core/api/dio_factory.dart';
import 'package:ifix_tech/core/constants/app_colors.dart';
import 'package:ifix_tech/core/constants/app_constants.dart';
import 'package:ifix_tech/core/constants/app_text_styles.dart';
import 'package:ifix_tech/core/data/repos/common_repo.dart';
import 'package:ifix_tech/core/routing/app_router.dart';
import 'package:ifix_tech/core/widgets/ifix_button.dart';
import 'package:ifix_tech/core/widgets/ifix_card.dart';
import 'package:ifix_tech/core/widgets/ifix_text_field.dart';
import 'package:ifix_tech/features/auth/logic/auth_cubit.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _specialty;
  int? _selectedCityId;
  String? _idPhotoPath;
  String? _avatarPath;
  List<dynamic> _cities = [];
  bool _fetchingCities = true;
  bool _uploadingId = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await CommonRepository().getCities();
      setState(() {
        _cities = cities;
        _fetchingCities = false;
      });
    } catch (e) {
      setState(() => _fetchingCities = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      if (type == 'id_photo') _uploadingId = true;
      if (type == 'avatar') _uploadingAvatar = true;
    });

    try {
      final dio = await DioFactory.getDio();
      final formData = FormData.fromMap({
        'type': type,
        'document': await MultipartFile.fromFile(pickedFile.path),
      });
      final response = await dio.post('documents/upload', data: formData);

      if (response.data['status'] == true) {
        setState(() {
          if (type == 'id_photo') _idPhotoPath = response.data['data']['path'];
          if (type == 'avatar') _avatarPath = response.data['data']['path'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.data['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء الرفع')));
    } finally {
      setState(() {
        if (type == 'id_photo') _uploadingId = false;
        if (type == 'avatar') _uploadingAvatar = false;
      });
    }
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_specialty == null || _selectedCityId == null || _idPhotoPath == null || _avatarPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى استكمال جميع البيانات ورفع الوثائق', style: TextStyle(fontFamily: 'Cairo'))));
      return;
    }
    context.read<AuthCubit>().register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      password: _passCtrl.text,
      cityId: _selectedCityId!,
      specialty: _specialty!,
      idPhoto: _idPhotoPath!,
      avatar: _avatarPath!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppRoutes.pendingApproval);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo'))));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تسجيل فني جديد'),
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.welcome),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingHorizontal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('انضم إلينا اليوم', style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text('سجل بياناتك وانتظر مراجعة طلبك من قبل الإدارة', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 24),
                IFixTextField(
                  hint: 'الاسم الكامل',
                  label: 'الاسم الكامل',
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 3 ? 'الاسم قصير جداً' : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: 'email@example.com',
                  label: 'البريد الإلكتروني',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) => (v?.isEmpty ?? true) ? 'البريد الإلكتروني مطلوب' : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: '09xxxxxxxx',
                  label: 'رقم الجوال',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 9 ? 'رقم جوال غير صالح' : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixDropdown<String>(
                  hint: 'التخصص',
                  value: _specialty,
                  items: ['مكيفات', 'سباكة', 'كهرباء', 'دهانات', 'نجارة'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => _specialty = v),
                ),
                const SizedBox(height: AppConstants.spacingMD),
                _fetchingCities
                    ? const Center(child: CircularProgressIndicator())
                    : IFixDropdown<int>(
                        hint: 'المدينة',
                        value: _selectedCityId,
                        items: _cities.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['name_ar']))).toList(),
                        onChanged: (v) => setState(() => _selectedCityId = v),
                      ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: 'كلمة المرور',
                  label: 'كلمة المرور',
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 6 ? 'كلمة المرور قصيرة' : null,
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'الوثائق الثبوتية'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _UploadCard(label: 'صورة الهوية', path: _idPhotoPath, isLoading: _uploadingId, onTap: () => _pickAndUploadImage('id_photo'))),
                    const SizedBox(width: 12),
                    Expanded(child: _UploadCard(label: 'الصورة الشخصية', path: _avatarPath, isLoading: _uploadingAvatar, onTap: () => _pickAndUploadImage('avatar'))),
                  ],
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    return IFixButton(
                      label: 'تقديم الطلب',
                      onTap: _onRegister,
                      isLoading: state is AuthLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  final String label;
  final String? path;
  final bool isLoading;
  final VoidCallback onTap;
  const _UploadCard({required this.label, this.path, this.isLoading = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(color: path != null ? AppColors.success : AppColors.border, width: path != null ? 1.5 : 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator()
            else
              Icon(path != null ? Icons.check_circle_rounded : Icons.cloud_upload_outlined, color: path != null ? AppColors.success : AppColors.accent, size: 32),
            const SizedBox(height: 8),
            Text(path != null ? 'تم الرفع' : label, style: AppTextStyles.bodySmall.copyWith(color: path != null ? AppColors.success : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
