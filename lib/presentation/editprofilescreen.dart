import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/models/user_profile.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  File? _avatarImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.user.username);
    _emailController = TextEditingController(text: widget.profile.user.email);
    _phoneController = TextEditingController(
      text: widget.profile.user.phoneNumber,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (pickedFile == null || !mounted) {
      return;
    }

    // Crop the image to 1:1 aspect ratio
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: kEspressoColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile == null || !mounted) {
      return;
    }

    setState(() {
      _avatarImage = File(croppedFile.path);
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final formData = FormData.fromMap(<String, dynamic>{
        'name': name,
        'email': email,
        'phone': phone,
        if (_avatarImage != null)
          'profileImage': await MultipartFile.fromFile(
            _avatarImage!.path,
            filename: _avatarImage!.path.split('/').last,
          ),
      });

      final response = await _dio.put<Map<String, dynamic>>(
        AppConstants.profile,
        data: formData,
        options: Options(
          headers: <String, dynamic>{'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('Response: ${response.data}');

      final data = response.data ?? <String, dynamic>{};
      if (response.statusCode == 200 && data['success'] == true) {
        final userJson =
            data['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
        final updatedProfile = UserProfile(
          user: UserData(
            username: (userJson['username'] as String?) ?? name,
            email: email,
            phoneNumber: phone,
            profileImage:
                (userJson['profileImage'] as String?) ??
                widget.profile.user.profileImage,
            favoriteBeauticians: widget.profile.user.favoriteBeauticians,
          ),
          stats: widget.profile.stats,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        Navigator.of(context).pop(updatedProfile);
      } else {
        final message =
            (data['message'] as String?) ?? 'Profile update failed.';
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] as String?) ?? 'Profile update failed.'
          : 'Profile update failed. Please try again.';
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);

    return Scaffold(
      backgroundColor: kWarmGrey50,
      appBar: AppBar(
        backgroundColor: kWarmGrey50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.inter(
            fontSize: 14 * scale,
            letterSpacing: 3,
            fontWeight: FontWeight.w500,
            color: kCharcoalColor,
          ),
        ),
        iconTheme: const IconThemeData(color: kCharcoalColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 24 * scale,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileImage(scale),
            SizedBox(height: 28 * scale),
            _buildInputField('Full Name', _nameController, hintText: 'Asha'),
            SizedBox(height: 16 * scale),
            _buildInputField(
              'Email',
              _emailController,
              hintText: 'asha@example.com',
              inputType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16 * scale),
            _buildInputField(
              'Phone Number',
              _phoneController,
              hintText: '9876543210',
              inputType: TextInputType.phone,
            ),
            SizedBox(height: 16 * scale),
            _buildReadOnlyField(
              'Membership',
              widget.profile.stats.tier.toUpperCase(),
            ),
            SizedBox(height: 32 * scale),
            SizedBox(
              height: 52 * scale,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kEspressoColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            kIvoryColor,
                          ),
                        ),
                      )
                    : Text(
                        'SAVE CHANGES',
                        style: GoogleFonts.inter(
                          fontSize: 13 * scale,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w500,
                          color: kIvoryColor,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(double scale) {
    final profileImage = widget.profile.user.profileImage;
    final imageProvider = _avatarImage != null
        ? FileImage(_avatarImage!) as ImageProvider
        : (profileImage.isNotEmpty
              ? NetworkImage(
                  profileImage.startsWith('http')
                      ? profileImage
                      : 'https://sidi.mobilegear.co.in$profileImage',
                )
              : null);

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 52 * scale,
              backgroundColor: kWarmGrey200,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person, size: 44 * scale, color: kWarmGrey600)
                  : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 34 * scale,
                  height: 34 * scale,
                  decoration: BoxDecoration(
                    color: kEspressoColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: kWarmGrey50, width: 2),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 18 * scale,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18 * scale),
        Text(
          'Update your details here',
          style: GoogleFonts.inter(fontSize: 12 * scale, color: kWarmGrey600),
        ),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    String hintText = '',
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: kInputHintStyle,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kWarmGrey200),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kEspressoColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: kLabelTextStyle),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: kWarmGrey50,
            border: Border.all(color: kWarmGrey200),
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: kCharcoalColor),
          ),
        ),
      ],
    );
  }
}
