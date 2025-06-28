import 'package:flutter/material.dart';
import 'package:sanjeevika/view/screens/chat/ai_chat_screen.dart';
import 'package:sanjeevika/viewmodels/data_controller.dart';
import 'package:sanjeevika/view/screens/emergency/emergency.dart';
import 'package:sanjeevika/view/screens/auth/login_page.dart';
import 'package:get/get.dart';
import 'package:sanjeevika/view/screens/profile/yajurnew_information_form.dart';
import 'package:sanjeevika/view/screens/medicine/my_medicine.dart';
import 'package:sanjeevika/view/screens/profile/yajurnew_myprofile.dart';
import 'package:sanjeevika/utils/functions_uses.dart';

class CustomSideBar extends StatefulWidget {
  const CustomSideBar({super.key});

  // Color constants for better maintainability
  static const Color _primaryGreen = Color(0xFF16833D);
  static const Color _lightGreen = Color(0xFFDEF1D8);
  static const Color _textColor = Color(0xFF2D3142);
  static const Color _iconColor = Color(0xFF16833D);

  @override
  State<CustomSideBar> createState() => _CustomSideBarState();
}

class _CustomSideBarState extends State<CustomSideBar> {
  late Datacontroller data;

  @override
  void initState() {
    super.initState();
    data = Get.find<Datacontroller>();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Drawer(
      elevation: 10.0,
      child: Column(
        children: [
          // Elegant header with gradient and better typography
          _buildModernHeader(width, height),

          // Main navigation area
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: _buildNavigationMenu(context, width, height),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a modern header with gradient background
  Widget _buildModernHeader(double width, double height) {
    return Container(
      width: double.infinity,
      height: height * 0.25, // 25% of screen height
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffD5FFA6),
            Color(0xffffffff),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomSideBar._primaryGreen.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.05), // 2% of screen height

            // App logo and name
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04), // 4% of screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(
                    image: const AssetImage("assets/images/logo_image.png"),
                    width: width * 0.15, // 15% of screen width
                    height: width * 0.15, // Keep aspect ratio square
                  ),
                  SizedBox(width: width * 0.03), // 3% of screen width
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sanjeevika',
                          style: style_(
                            fontSize: width * 0.065, // 6.5% of screen width
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff005014),
                          ),
                        ),
                        Text(
                          'Your Health Companion',
                          style: style_(
                            fontSize: width * 0.035, // 3.5% of screen width
                            fontWeight: FontWeight.w600,
                            color: const Color(0xff005014),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02), // 2% of screen height

            // Welcome message or user info section
            Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width * 0.04), // 4% of screen width
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04, // 4% of screen width
                vertical: height * 0.015, // 1.5% of screen height
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius:
                    BorderRadius.circular(width * 0.03), // 3% of screen width
                border: Border.all(color: const Color(0xff97FF8D)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: CustomSideBar._primaryGreen,
                    size: width * 0.05, // 5% of screen width
                  ),
                  SizedBox(width: width * 0.02), // 2% of screen width
                  Expanded(
                    child: Text(
                      'Stay healthy, stay happy!',
                      style: style_(
                        fontSize: width * 0.035, // 3.5% of screen width
                        fontWeight: FontWeight.w500,
                        color: CustomSideBar._primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main navigation menu
  Widget _buildNavigationMenu(
      BuildContext context, double width, double height) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: height * 0.02), // 2% of screen height

          // Primary navigation items
          _buildMenuSection([
            _MenuItemData(
              icon: Icons.home_rounded,
              title: 'Home',
              onTap: () => _navigateToHome(context),
            ),
            _MenuItemData(
              icon: Icons.medication_rounded,
              title: 'My Medicine',
              onTap: () => _navigateToMedicine(context),
            ),
            _MenuItemData(
              icon: Icons.edit,
              title: 'Edit Patient Details',
              onTap: () => Get.to(
                InformationForm(),
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 350),
              ),
            ),
            _MenuItemData(
              icon: Icons.chat_bubble_outline,
              title: 'AI Assistant',
              onTap: () => Get.to(
                AiPage(),
                transition: Transition.leftToRight,
                duration: const Duration(milliseconds: 350),
              ),
            ),
            _MenuItemData(
              icon: Icons.emergency_rounded,
              title: 'Emergency Contacts',
              onTap: () => Get.to(
                EmergencyPage(),
                transition: Transition.leftToRight,
              ),
            ),
          ], width, height),

          SizedBox(height: height * 0.02), // 2% of screen height

          // Divider for visual separation
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: width * 0.04, // 4% of screen width
              vertical: height * 0.015, // 1.5% of screen height
            ),
            height: 1,
            color: Colors.grey.shade200,
          ),

          // Logout section
          Container(
            margin: EdgeInsets.all(width * 0.04), // 4% of screen width
            child: _buildLogoutButton(context, width, height),
          ),
          SizedBox(height: height * 0.05),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '~Made by Team Sanjeevni 💚',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: Color(0xff005014),
                  fontSize: width * 0.04,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a section of menu items
  Widget _buildMenuSection(
      List<_MenuItemData> items, double width, double height) {
    return Column(
      children: items
          .map((item) => _buildEnhancedMenuItem(
                icon: item.icon,
                title: item.title,
                onTap: item.onTap,
                width: width,
                height: height,
              ))
          .toList(),
    );
  }

  /// Creates an enhanced menu item with better styling
  Widget _buildEnhancedMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required double width,
    required double height,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.02, // 2% of screen width
        vertical: height * 0.003, // 0.3% of screen height
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(width * 0.03), // 3% of screen width
          splashColor: CustomSideBar._lightGreen.withOpacity(0.3),
          highlightColor: CustomSideBar._lightGreen.withOpacity(0.2),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.04, // 4% of screen width
              vertical: height * 0.015, // 1.5% of screen height
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(width * 0.02), // 2% of screen width
                  decoration: BoxDecoration(
                    color: CustomSideBar._lightGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(
                        width * 0.02), // 2% of screen width
                  ),
                  child: Icon(
                    icon,
                    color: CustomSideBar._iconColor,
                    size: width * 0.05, // 5% of screen width
                  ),
                ),
                SizedBox(width: width * 0.04), // 4% of screen width
                Expanded(
                  child: Text(
                    title,
                    style: style_(
                      fontSize: width * 0.04, // 4% of screen width
                      fontWeight: FontWeight.w500,
                      color: CustomSideBar._textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: width * 0.035, // 3.5% of screen width
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Creates a stylish logout button
  Widget _buildLogoutButton(BuildContext context, double width, double height) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleLogout(context),
        borderRadius: BorderRadius.circular(width * 0.03), // 3% of screen width
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.04, // 4% of screen width
            vertical: height * 0.015, // 1.5% of screen height
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.02), // 2% of screen width
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(width * 0.02), // 2% of screen width
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: width * 0.05, // 5% of screen width
                ),
              ),
              SizedBox(width: width * 0.04), // 4% of screen width
              Expanded(
                child: Text(
                  'Logout',
                  style: style_(
                    fontSize: width * 0.04, // 4% of screen width
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation Methods
  void _navigateToHome(BuildContext context) {
    Navigator.pop(context);
    debugPrint('Navigating to Home');
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MyProfilePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToMedicine(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MyMedicinePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pop(context);
    debugPrint('Navigating to Settings');
    // TODO: Implement settings page navigation
  }

  void _handleLogout(BuildContext context) {
    _showModernLogoutDialog(context);
  }

  /// Shows a modern, styled logout confirmation dialog
  void _showModernLogoutDialog(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(width * 0.05), // 5% of screen width
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.02), // 2% of screen width
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(width * 0.02), // 2% of screen width
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: Colors.red.shade600,
                  size: width * 0.06, // 6% of screen width
                ),
              ),
              SizedBox(width: width * 0.03), // 3% of screen width
              Text(
                'Logout',
                style: style_(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05, // 5% of screen width
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You\'ll need to sign in again to access your account.',
            style: style_(
              fontSize: width * 0.04, // 4% of screen width
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, // 6% of screen width
                  vertical: height * 0.015, // 1.5% of screen height
                ),
              ),
              child: Text(
                'Cancel',
                style: style_(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.04, // 4% of screen width
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06, // 6% of screen width
                  vertical: height * 0.015, // 1.5% of screen height
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(width * 0.02), // 2% of screen width
                ),
              ),
              child: Text(
                'Logout',
                style: style_(
                  fontWeight: FontWeight.w600,
                  fontSize: width * 0.04, // 4% of screen width
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Performs the actual logout operation
  void _performLogout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    debugPrint('User logged out successfully');

    // Navigate to login page and clear all previous routes
    Get.offAll(() => LoginPage());

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged out successfully',
          style: style_(
            color: Colors.white,
            fontSize: width * 0.04, // 4% of screen width
          ),
        ),
        backgroundColor: CustomSideBar._primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(width * 0.02), // 2% of screen width
        ),
      ),
    );
  }
}

/// Data class for menu items to improve code organization
class _MenuItemData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
