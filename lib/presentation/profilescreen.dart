import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/controller/logoutcontroller.dart';
import 'package:sidi/presentation/appointments_screen.dart';
import 'package:sidi/presentation/editprofilescreen.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/models/user_profile.dart';
import 'package:sidi/utils/app_constants.dart';
import 'package:sidi/utils/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LogoutController _logoutController = LogoutController();
  final ImagePicker _imagePicker = ImagePicker();
  final Dio _dio = Dio();
  File? _avatarImage;
  bool _isLoading = true;
  String? _errorMessage;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final token = await _getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication token is missing.';
      });
      return;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        AppConstants.profile,
        options: Options(
          headers: <String, dynamic>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      if (response.statusCode == 200 && data['success'] == true) {
        final profile = UserProfile.fromJson(data);
        if (!mounted) return;
        setState(() {
          _profile = profile;
          _avatarImage = null;
          _isLoading = false;
        });
      } else {
        final message =
            (data['message'] as String?) ?? 'Unable to load profile.';
        if (!mounted) return;
        setState(() {
          _errorMessage = message;
          _isLoading = false;
        });
      }
    } on DioException catch (error) {
      final responseData = error.response?.data;
      final message = responseData is Map<String, dynamic>
          ? (responseData['message'] as String?) ?? 'Unable to load profile.'
          : 'Unable to load profile. Please check your connection.';
      if (!mounted) return;
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Something went wrong while loading your profile.';
        _isLoading = false;
      });
    }
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

    setState(() {
      _avatarImage = File(pickedFile.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 390).clamp(0.82, 1.0);

    return Scaffold(
      backgroundColor: kWarmGrey50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: kWarmGrey50,
            surfaceTintColor: kWarmGrey50,
            centerTitle: true,
            title: Text(
              'ACCOUNT',
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                letterSpacing: 5,
                fontWeight: FontWeight.w400,
                color: kCharcoalColor,
              ),
            ),
          ),
          if (_isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: kEspressoColor),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14 * scale,
                        color: kCharcoalColor,
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    OutlinedButton(
                      onPressed: _fetchUserProfile,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kWarmGrey200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'RETRY',
                        style: GoogleFonts.inter(
                          fontSize: 12 * scale,
                          letterSpacing: 2,
                          color: kAccentGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildProfileHeader(scale)),
            SliverToBoxAdapter(child: _buildStatStrip(scale)),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'MANAGEMENT',
                items: [
                  _ProfileItemData(
                    Icons.edit_outlined,
                    'Edit Profile',
                    onTap: () async {
                      if (_profile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile not loaded yet.'),
                          ),
                        );
                        return;
                      }

                      final updatedProfile = await Navigator.of(context)
                          .push<UserProfile?>(
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProfileScreen(profile: _profile!),
                            ),
                          );

                      if (updatedProfile != null && mounted) {
                        setState(() {
                          _profile = updatedProfile;
                        });
                        await _fetchUserProfile();
                      }
                    },
                  ),
                  _ProfileItemData(
                    Icons.calendar_month_outlined,
                    'My Bookings',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppointmentsScreen(),
                        ),
                      );
                    },
                  ),
                  const _ProfileItemData(
                    Icons.credit_card_outlined,
                    'Payments & Billing',
                  ),
                  const _ProfileItemData(
                    Icons.auto_awesome_outlined,
                    'Favorite Stylists',
                  ),
                ],
                scale: scale,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'APPLICATION',
                items: const [
                  _ProfileItemData(Icons.tune, 'Settings'),
                  _ProfileItemData(Icons.help_outline, 'Support Center'),
                ],
                scale: scale,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24 * scale,
                  24 * scale,
                  24 * scale,
                  110 * scale,
                ),
                child: OutlinedButton(
                  onPressed: () async {
                    final token = await _getToken();
                    if (token == null || token.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No token found.')),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );
                    final success = await _logoutController.logout(token);
                    Navigator.of(context).pop();
                    if (success) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _logoutController.errorMessage ?? 'Logout failed.',
                          ),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(42 * scale),
                    side: BorderSide(color: kWarmGrey200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                  ),
                  child: Text(
                    'SIGN OUT',
                    style: GoogleFonts.inter(
                      fontSize: 9 * scale,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                      color: kAccentGold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<String?> _getToken() async {
    final token = await TokenStorage.getToken();
    debugPrint(
      '[ProfileScreen] Stored auth token: ${token == null ? '<null>' : token}',
    );
    return token;
  }

  Widget _buildProfileHeader(double scale) {
    final name = _profile?.user.username ?? 'Customer';
    final tier = _profile?.stats.tier.toUpperCase() ?? 'MEMBER';
    final joined = _profile != null
        ? 'MEMBER SINCE ${_formatMemberSince(_profile!.stats.memberSince)}'
        : 'MEMBER SINCE 2022';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        14 * scale,
        24 * scale,
        20 * scale,
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92 * scale,
                height: 92 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFC9BDAF),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: _avatarImage != null
                      ? Image.file(_avatarImage!, fit: BoxFit.cover)
                      : (_profile?.user.profileImage.isNotEmpty == true
                            ? Image.network(
                                _profile!.user.profileImage.startsWith('http')
                                    ? _profile!.user.profileImage
                                    : 'https://sidi.mobilegear.co.in${_profile!.user.profileImage}',
                                // : 'https://i.pinimg.com/736x/8b/f4/d6/8bf4d6706d34d799dcc6a6c8cde495ed.jpg',
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                'https://randomuser.me/api/portraits/women/44.jpg',
                                fit: BoxFit.cover,
                              )),
                ),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: InkWell(
                  onTap: _pickProfileImage,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 30 * scale,
                    height: 30 * scale,
                    decoration: BoxDecoration(
                      color: kEspressoColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kWarmGrey50, width: 2),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 15 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 18 * scale),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 34 * scale,
              fontStyle: FontStyle.italic,
              color: kCharcoalColor,
              height: 0.95,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * scale),
          Text(
            tier,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22 * scale,
              fontStyle: FontStyle.italic,
              color: kAccentGold,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            joined,
            style: GoogleFonts.inter(
              fontSize: 9 * scale,
              letterSpacing: 3,
              color: kWarmGrey600,
            ),
          ),
          if (_profile != null) ...[
            SizedBox(height: 8 * scale),
            Text(
              _profile!.user.email,
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                color: kWarmGrey600,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              _profile!.user.phoneNumber,
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                color: kWarmGrey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatStrip(double scale) {
    final bookings = _profile?.stats.totalBookings.toString() ?? '0';
    final reviews = _profile?.stats.totalReviews.toString() ?? '0';

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 18 * scale,
        horizontal: 20 * scale,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kWarmGrey200),
          bottom: BorderSide(color: kWarmGrey200),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _statCell(bookings, 'BOOKINGS', scale)),
          Expanded(child: _statCell(reviews, 'REVIEWS', scale)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_ProfileItemData> items,
    required double scale,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 24 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 28 * scale),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 9 * scale,
                letterSpacing: 4,
                color: kAccentGold,
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          ...items.map((item) => _buildSectionRow(item, scale)),
        ],
      ),
    );
  }

  Widget _buildSectionRow(_ProfileItemData item, double scale) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kWarmGrey200)),
      ),
      child: ListTile(
        minVerticalPadding: 8 * scale,
        contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
        leading: Icon(item.icon, size: 17 * scale, color: kWarmGrey600),
        title: Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w300,
            color: kCharcoalColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: kWarmGrey200,
          size: 17 * scale,
        ),
        onTap: item.onTap,
      ),
    );
  }

  Widget _statCell(String value, String label, double scale) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.playfairDisplay(
            fontSize: 26 * scale,
            color: kCharcoalColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6 * scale),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9 * scale,
            letterSpacing: 3,
            color: kAccentGold,
          ),
        ),
      ],
    );
  }

  String _formatMemberSince(String value) {
    try {
      final date = DateTime.parse(value).toLocal();
      const monthNames = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    } catch (_) {
      return value.split('T').first;
    }
  }
}

class _ProfileItemData {
  const _ProfileItemData(this.icon, this.label, {this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}
