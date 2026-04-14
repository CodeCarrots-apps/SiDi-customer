import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sidi/constant/constants.dart';
import 'package:sidi/controller/logoutcontroller.dart';
import 'package:sidi/presentation/appointments_screen.dart';
import 'package:sidi/presentation/loginscreen.dart';
import 'package:sidi/utils/token_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LogoutController _logoutController = LogoutController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _avatarImage;

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
          SliverToBoxAdapter(child: _buildProfileHeader(scale)),
          SliverToBoxAdapter(child: _buildStatStrip(scale)),
          SliverToBoxAdapter(
            child: _buildSection(
              title: 'MANAGEMENT',
              items: [
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
                  Navigator.of(context).pop(); // Remove loading dialog
                  if (success) {
                    // Navigate to splash screen and clear all previous routes
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
                      : Image.network(
                          'https://randomuser.me/api/portraits/women/44.jpg',
                          fit: BoxFit.cover,
                        ),
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
            'Isabella Sterling',
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
            'Gold Member',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22 * scale,
              fontStyle: FontStyle.italic,
              color: kAccentGold,
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            'MEMBER SINCE 2022',
            style: GoogleFonts.inter(
              fontSize: 9 * scale,
              letterSpacing: 3,
              color: kWarmGrey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatStrip(double scale) {
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
          Expanded(child: _statCell('12', 'BOOKINGS', scale)),
          Expanded(child: _statCell('4', 'REVIEWS', scale)),
        ],
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
}

class _ProfileItemData {
  const _ProfileItemData(this.icon, this.label, {this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}
