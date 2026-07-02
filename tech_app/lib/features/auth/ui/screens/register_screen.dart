import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/data/repos/common_repo.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/widgets/ifix_button.dart';
import '../../../../core/widgets/ifix_card.dart';
import '../../../../core/widgets/ifix_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../logic/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCityName;
  List<dynamic> _cities = [];
  bool _fetchingCities = true;

  List<dynamic> _services = [];
  final List<int> _selectedServiceIds = [];
  bool _fetchingServices = true;

  String? _idDocumentPath;

  double? _lat;
  double? _lng;
  bool _fetchingLocation = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _loadServices();
    _fetchLocation();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await CommonRepository().getCities();
      if (mounted) setState(() { _cities = cities; _fetchingCities = false; });
    } catch (_) {
      if (mounted) setState(() => _fetchingCities = false);
    }
  }

  Future<void> _loadServices() async {
    try {
      final services = await CommonRepository().getCategories();
      if (mounted) setState(() { _services = services; _fetchingServices = false; });
    } catch (_) {
      if (mounted) setState(() => _fetchingServices = false);
    }
  }

  Future<void> _fetchLocation() async {
    if (!mounted) return;
    setState(() { _fetchingLocation = true; _locationError = null; });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() { _fetchingLocation = false; _locationError = 'location_service_disabled'.tr(); });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() { _fetchingLocation = false; _locationError = 'location_permission_denied'.tr(); });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) setState(() { _lat = position.latitude; _lng = position.longitude; _fetchingLocation = false; });
    } catch (_) {
      if (mounted) setState(() { _fetchingLocation = false; _locationError = 'تعذّر جلب الموقع'; });
    }
  }

  Future<void> _pickIdDocument() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) setState(() => _idDocumentPath = picked.path);
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCityName == null) {
      _showSnack('please_select_city'.tr());
      return;
    }
    if (_selectedServiceIds.isEmpty) {
      _showSnack('please_select_service'.tr());
      return;
    }
    if (_idDocumentPath == null) {
      _showSnack('please_upload_id'.tr());
      return;
    }
    if (_lat == null || _lng == null) {
      _showSnack('please_allow_location'.tr());
      return;
    }

    context.read<AuthCubit>().register(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      city: _selectedCityName!,
      lat: _lat!,
      lng: _lng!,
      idDocumentPath: _idDocumentPath!,
      serviceIds: _selectedServiceIds,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppRoutes.pendingApproval);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message, style: Theme.of(context).textTheme.bodyMedium)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('register_new_tech'.tr()),
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
                Text('join_today'.tr(), style: AppTextStyles.headlineLarge),
                const SizedBox(height: 8),
                Text('join_subtitle'.tr(), style: AppTextStyles.bodyMedium),
                const SizedBox(height: 24),
                IFixTextField(
                  hint: 'full_name'.tr(),
                  label: 'full_name'.tr(),
                  controller: _nameCtrl,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 3 ? 'name_too_short'.tr() : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: 'phone_hint'.tr(),
                  label: 'phone'.tr(),
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 9 ? 'invalid_phone'.tr() : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                IFixTextField(
                  hint: 'password_hint'.tr(),
                  label: 'password'.tr(),
                  controller: _passCtrl,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  validator: (v) => (v?.length ?? 0) < 8 ? 'password_short'.tr() : null,
                ),
                const SizedBox(height: AppConstants.spacingMD),
                _fetchingCities
                    ? const Center(child: CircularProgressIndicator())
                    : IFixDropdown<String>(
                        hint: 'city'.tr(),
                        value: _selectedCityName,
                        items: _cities
                            .map((c) => DropdownMenuItem<String>(value: c['name'].toString(), child: Text(c['name'].toString())))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedCityName = v),
                      ),
                const SizedBox(height: AppConstants.spacingMD),
                SectionHeader(title: 'services_provided'.tr()),
                const SizedBox(height: 8),
                _fetchingServices
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _services.map((s) {
                          final id = s['id'] as int;
                          final name = s['name'].toString();
                          final selected = _selectedServiceIds.contains(id);
                          return FilterChip(
                            label: Text(name),
                            selected: selected,
                            onSelected: (v) => setState(() {
                              if (v) { _selectedServiceIds.add(id); } else { _selectedServiceIds.remove(id); }
                            }),
                          );
                        }).toList(),
                      ),
                const SizedBox(height: AppConstants.spacingMD),
                SectionHeader(title: 'documents'.tr()),
                const SizedBox(height: 12),
                IFixCard(
                  onTap: _pickIdDocument,
                  child: Row(
                    children: [
                      Icon(
                        _idDocumentPath != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                        color: _idDocumentPath != null ? AppColors.success : AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _idDocumentPath != null ? 'id_selected'.tr() : 'upload_id'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _idDocumentPath != null ? AppColors.success : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMD),
                SectionHeader(title: 'location'.tr()),
                const SizedBox(height: 12),
                IFixCard(
                  onTap: _locationError != null ? _fetchLocation : null,
                  child: Row(
                    children: [
                      if (_fetchingLocation)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        Icon(
                          _lat != null ? Icons.location_on_rounded : Icons.location_off_rounded,
                          color: _lat != null ? AppColors.success : (_locationError != null ? AppColors.error : AppColors.accent),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _fetchingLocation
                              ? 'fetching_location'.tr()
                              : _lat != null
                                  ? 'location_detected'.tr()
                                  : _locationError ?? 'fetching_location'.tr(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _lat != null ? AppColors.success : (_locationError != null ? AppColors.error : AppColors.textSecondary),
                          ),
                        ),
                      ),
                      if (_locationError != null)
                        Text('retry'.tr(), style: AppTextStyles.labelMedium.copyWith(color: AppColors.accent)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) => IFixButton(
                    label: 'submit_request'.tr(),
                    onTap: _onRegister,
                    isLoading: state is AuthLoading,
                  ),
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
