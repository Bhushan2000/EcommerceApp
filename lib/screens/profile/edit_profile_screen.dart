import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/address_lookup_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../checkout/map_address_picker_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.displayName;
      _phoneController.text = user.phoneNumber ?? '';
      _streetController.text = user.street ?? '';
      _cityController.text = user.city ?? '';
      _stateController.text = user.state ?? '';
      _zipController.text = user.zipCode ?? '';
      _countryController.text = user.country ?? 'United States';
    } else {
      _nameController.text = 'Alex Morgan';
      _phoneController.text = '+1 (555) 019-2834';
      _streetController.text = '742 Evergreen Terrace';
      _cityController.text = 'Springfield';
      _stateController.text = 'OR';
      _zipController.text = '97477';
      _countryController.text = 'United States';
    }

    // Auto-fetch state whenever user enters city
    _cityController.addListener(_onCityChanged);
  }

  void _onCityChanged() {
    final query = _cityController.text.trim();
    if (query.isNotEmpty) {
      final detectedState = AddressLookupService.lookupState(query);
      if (detectedState != null && _stateController.text != detectedState) {
        setState(() {
          _stateController.text = detectedState;
        });
      }
    }
  }

  @override
  void dispose() {
    _cityController.removeListener(_onCityChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => MapAddressPickerScreen(
          initialStreet: _streetController.text,
          initialCity: _cityController.text,
          initialState: _stateController.text,
          initialZip: _zipController.text,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (result['street']?.isNotEmpty == true) {
          _streetController.text = result['street']!;
        }
        if (result['city']?.isNotEmpty == true) {
          _cityController.text = result['city']!;
        }
        if (result['state']?.isNotEmpty == true) {
          _stateController.text = result['state']!;
        }
        if (result['zip']?.isNotEmpty == true) {
          _zipController.text = result['zip']!;
        }
        if (result['country']?.isNotEmpty == true) {
          _countryController.text = result['country']!;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Address loaded from Map: ${_streetController.text}'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    final auth = context.read<AuthProvider>();
    final currentUser = auth.user;
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      displayName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipCode: _zipController.text.trim(),
      country: _countryController.text.trim(),
    );

    final success = await auth.updateProfile(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Profile and address updated successfully!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile & Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              label: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            // Address Section Header with Map Picker Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shipping Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _openMapPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Pick on Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: _streetController,
              label: 'Street Address',
              prefixIcon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _cityController,
                    label: 'City (Auto-fetches State)',
                    hint: 'e.g. Springfield / Mumbai',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _stateController,
                    label: 'State / Province',
                    hint: 'e.g. OR / Maharashtra',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _zipController,
                    label: 'ZIP / Postal Code',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _countryController,
                    label: 'Country',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Save Changes',
              icon: Icons.save_rounded,
              isLoading: auth.isLoading,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
