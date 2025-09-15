import 'package:dashboard_template_dribbble/providers/theme_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// Import your project's specific files
import '../../utils/media_query_values.dart';
import '../../providers/auth_provider.dart'; // 👈 Import AuthProvider
import '../widgets/custom_button.dart';

class Header extends StatefulWidget {
  const Header({
    super.key,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  Timer? _timer;
  String _currentTime = '';
  // final bool _isDarkMode = true; // Assuming the default theme is dark

  @override
  void initState() {
    super.initState();
    // Update the time every second
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _updateTime() {
    if (mounted) { // Check if the widget is still in the tree
      setState(() {
        // Format the current time
        _currentTime = DateFormat('EEE, d MMM yyyy HH:mm:ss').format(DateTime.now());
      });
    }
  }

  void _toggleTheme() {
    final themeProvider = context.read<ThemeProvider>();
    final isCurrentlyDark = themeProvider.themeMode == ThemeMode.dark;

    themeProvider.setThemeMode(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }

  void _showLanguageDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              onTap: () {
                // Change to English
                context.setLocale(const Locale('en'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('සිංහල'), // Sinhala text
              onTap: () {
                // Change to Sinhala
                context.setLocale(const Locale('si'));
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('தமிழ்'), // Tamil text
              onTap: () {
                // Change to Tamil
                context.setLocale(const Locale('ta'));
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      height: context.height * 0.28,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: const BoxDecoration(
        image: DecorationImage(
          alignment: Alignment.bottomCenter,
          image: AssetImage(
            'assets/images/header_image.jpeg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
        children: [
          // Left side: Current time
          Text(
            _currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(2.0, 2.0),
                  blurRadius: 4.0,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
          // Right side: Action buttons and user profile
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                width: context.width * 0.10,
                title: 'POS',
                onPressed: () {
                  print('POS button pressed');
                  Navigator.pushNamed(context, '/pos');
                },
              ),
              SizedBox(width: context.width * 0.01),
              IconButton(
              icon: Icon(
                isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              ),
              onPressed: _toggleTheme,
            ),
              SizedBox(width: context.width * 0.01),
              IconButton(
                icon: const Icon(Icons.translate ),
                onPressed: _showLanguageDialog,
              ),
              SizedBox(width: context.width * 0.01),
              const Icon(Icons.notifications),
              SizedBox(width: context.width * 0.01),
              _buildUserProfile(context, user),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the user profile section with a popup menu for logout.
  Widget _buildUserProfile(BuildContext context, User? user) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthProvider>().logout();
        }
      },
      tooltip: "Profile Options",
      color: Colors.grey[800], // A dark color for the popup menu
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20.0,
            backgroundColor: Colors.grey.shade800, // A fallback background color
            // Use the user's profile photo, or a default icon if not available.
            // backgroundImage: (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty)
            //     ? NetworkImage(user.profilePhoto!)
            //     : null,
            // child: (user?.profilePhoto == null || user!.profilePhoto!.isEmpty)
            //     ? const Icon(Icons.person, color: Colors.white70)
            //     : null,
          ),
          SizedBox(width: context.width * 0.007),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name ?? 'Guest', // Display user's name or 'Guest'
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: context.width * 0.005),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 12.0,
                    color: Colors.white70,
                  ),
                ],
              ),
              Text(
                user?.email ?? '', // Display user's email or an empty string
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ],
      ),
      // Define the items that appear in the popup menu.
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text('View Profile', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Logout', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}
