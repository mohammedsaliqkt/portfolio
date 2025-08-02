import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portfolio - Mohammed Saliq KT',
      theme: _buildTheme(),
      home: const PortfolioPage(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00E676),
        brightness: Brightness.dark,
        surface: const Color(0xFF0D0D0D),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      textTheme: ThemeData.dark().textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0D0D0D),
                  const Color(0xFF1A1A1A),
                  const Color(0xFF000000),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _getHorizontalPadding(constraints.maxWidth),
                      vertical: _getVerticalPadding(constraints.maxHeight),
                    ),
                    child: _buildResponsiveLayout(context, constraints),
                  ),
                ),
                // Floating dock on the right
                if (!_isMobile(constraints.maxWidth))
                  _buildFloatingDock(context, constraints),
                // Mobile contact buttons at bottom
                if (_isMobile(constraints.maxWidth))
                  _buildMobileContactBar(context, constraints),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _isMobile(double width) => width < 768;
  bool _isTablet(double width) => width >= 768 && width < 1024;

  double _getHorizontalPadding(double width) {
    if (width < 480) return 16;
    if (width < 768) return 24;
    if (width < 1024) return 32;
    if (width < 1440) return 48;
    return 64;
  }

  double _getVerticalPadding(double height) {
    if (height < 600) return 16;
    if (height < 800) return 24;
    return 32;
  }

  double _getDynamicSpacing(double height, double width) {
    if (width < 480) {
      return height * 0.02; // 2% of height for very small screens
    }
    if (width < 768) return height * 0.03; // 3% of height for mobile
    if (width < 1024) return height * 0.04; // 4% of height for tablet
    return height * 0.05; // 5% of height for desktop
  }

  double _getDynamicImageSize(double width, double height) {
    final baseSize = width < height ? width : height;
    if (width < 480) return baseSize * 0.25; // 25% of smallest dimension
    if (width < 768) return baseSize * 0.3; // 30% for mobile
    if (width < 1024)
      return baseSize * 0.35; // 35% for tablet (same as mobile layout)
    if (width < 1440) return baseSize * 0.35; // 35% for laptop (larger photo)
    return baseSize * 0.4; // 40% for large desktop (even larger photo)
  }

  double _getDynamicFontSize(double width, {required String textType}) {
    switch (textType) {
      case 'title':
        if (width < 480) return width * 0.08; // 8% of width
        if (width < 768) return width * 0.07; // 7% of width
        if (width < 1024) return width * 0.05; // 5% of width
        return width * 0.035; // 3.5% of width
      case 'subtitle':
        if (width < 480) return width * 0.05; // 5% of width
        if (width < 768) return width * 0.045; // 4.5% of width
        if (width < 1024) return width * 0.035; // 3.5% of width
        return width * 0.025; // 2.5% of width
      case 'body':
        if (width < 480) return width * 0.04; // 4% of width
        if (width < 768) return width * 0.035; // 3.5% of width
        if (width < 1024) return width * 0.025; // 2.5% of width
        return width * 0.018; // 1.8% of width
      default:
        return 16;
    }
  }

  Widget _buildResponsiveLayout(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;

    if (_isMobile(width) || _isTablet(width)) {
      return _buildMobileLayout(context, constraints);
    } else {
      return _buildDesktopLayout(context, constraints);
    }
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints) {
    final spacing = _getDynamicSpacing(
      constraints.maxHeight,
      constraints.maxWidth,
    );

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: spacing * 2),
          _buildProfileSection(context, constraints),
          SizedBox(height: spacing * 3), // Extra space for mobile contact bar
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    final showSideImage = constraints.maxWidth > 1200;
    final spacing = _getDynamicSpacing(
      constraints.maxHeight,
      constraints.maxWidth,
    );

    if (showSideImage) {
      // Two-column layout with image on the side
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: _buildProfileSection(context, constraints)),
          SizedBox(width: spacing * 2),
          Expanded(
            flex: 2,
            child: Center(
              child: _buildProfileImage(
                size: _getDynamicImageSize(
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Single column layout for smaller desktop screens
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: spacing),
            _buildProfileSection(context, constraints),
            SizedBox(height: spacing),
          ],
        ),
      );
    }
  }

  Widget _buildProfileSection(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final isMobileOrTablet = width < 1024; // Combined mobile and tablet
    final spacing = _getDynamicSpacing(height, width);
    final imageSize = _getDynamicImageSize(width, height);

    return Column(
      crossAxisAlignment:
          isMobileOrTablet
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isMobileOrTablet || width <= 1200)
          _buildProfileImage(size: imageSize),
        if (isMobileOrTablet || width <= 1200) SizedBox(height: spacing),

        Text(
          'MOHAMMED SALIQ KT',
          style: TextStyle(
            fontSize: _getDynamicFontSize(
              width,
              textType: 'title',
            ).clamp(24.0, 64.0),
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF5F5F5),
            letterSpacing: width * 0.001, // Dynamic letter spacing
            shadows: [
              Shadow(
                blurRadius: 20.0,
                color: const Color(0xFF64FFDA).withValues(alpha: 0.3),
                offset: const Offset(2.0, 2.0),
              ),
            ],
          ),
          textAlign: isMobileOrTablet ? TextAlign.center : TextAlign.left,
        ),

        SizedBox(height: spacing * 0.5),

        Text(
          'Flutter Developer',
          style: TextStyle(
            fontSize: _getDynamicFontSize(
              width,
              textType: 'subtitle',
            ).clamp(16.0, 32.0),
            fontWeight: FontWeight.w500,
            color: const Color(0xFF00E676),
            letterSpacing: width * 0.0005,
          ),
          textAlign: isMobileOrTablet ? TextAlign.center : TextAlign.left,
        ),

        SizedBox(height: spacing * 0.75),

        Text(
          'Creating beautiful, performant mobile and web applications with clean code and intuitive user experiences.',
          style: TextStyle(
            fontSize: _getDynamicFontSize(
              width,
              textType: 'body',
            ).clamp(14.0, 24.0),
            color: const Color(0xFFB0B0B0),
            height: 1.6,
          ),
          textAlign: isMobileOrTablet ? TextAlign.center : TextAlign.left,
          maxLines: isMobileOrTablet ? 4 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProfileImage({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [const Color(0xFF00E676), const Color(0xFF1DE9B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/images/img_photo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF1A1A1A),
              child: Icon(
                Icons.person,
                size: size * 0.4,
                color: const Color(0xFF666666),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingDock(BuildContext context, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final dockSize = (width * 0.05).clamp(35.0, 50.0); // 5% of width, clamped
    final spacing = height * 0.02; // 2% of height for spacing

    return Positioned(
      right: width * 0.03, // 3% from right edge
      top: height * 0.35,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing,
          horizontal: width * 0.01,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(width * 0.015),
          border: Border.all(color: const Color(0xFF333333), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDockButton(
              context: context,
              icon: FontAwesomeIcons.linkedin,
              color: const Color(0xFF0A66C2),
              tooltip: 'LinkedIn',
              url: 'https://linkedin.com/in/mohammedsaliqkt',
              size: dockSize,
            ),
            SizedBox(height: spacing),
            _buildDockButton(
              context: context,
              icon: FontAwesomeIcons.github,
              color: const Color(0xFF24292e),
              tooltip: 'GitHub',
              url: 'https://github.com/mohammedsaliqkt',
              size: dockSize,
            ),
            SizedBox(height: spacing),
            _buildDockButton(
              context: context,
              icon: Icons.email,
              color: const Color(0xFFEA4335),
              tooltip: 'Email',
              url: 'mailto:ktmohammedsaliq@gmail.com',
              size: dockSize,
            ),
            SizedBox(height: spacing),
            _buildDockButton(
              context: context,
              icon: Icons.download,
              color: const Color(0xFF00E676),
              tooltip: 'Download Resume',
              url: 'resume_download',
              size: dockSize,
              isResume: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileContactBar(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    final buttonSize = (width * 0.08).clamp(28.0, 40.0); // 8% of width, clamped

    return Positioned(
      bottom: height * 0.05, // 5% from bottom
      left: width * 0.05, // 5% from left
      right: width * 0.05, // 5% from right
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: height * 0.015, // 1.5% of height
          horizontal: width * 0.04, // 4% of width
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D0D).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(width * 0.06), // 6% of width
          border: Border.all(color: const Color(0xFF333333), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDockButton(
              context: context,
              icon: FontAwesomeIcons.linkedin,
              color: const Color(0xFF0A66C2),
              tooltip: 'LinkedIn',
              url: 'https://linkedin.com/in/mohammed-saliq-kt',
              size: buttonSize,
            ),
            _buildDockButton(
              context: context,
              icon: FontAwesomeIcons.github,
              color: const Color(0xFF24292e),
              tooltip: 'GitHub',
              url: 'https://github.com/mohammedsaliqkt',
              size: buttonSize,
            ),
            _buildDockButton(
              context: context,
              icon: Icons.email,
              color: const Color(0xFFEA4335),
              tooltip: 'Email',
              url: 'mailto:your.email@example.com',
              size: buttonSize,
            ),
            _buildDockButton(
              context: context,
              icon: Icons.download,
              color: const Color(0xFF00E676),
              tooltip: 'Download Resume',
              url: 'resume_download',
              size: buttonSize,
              isResume: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required String url,
    double size = 40,
    bool isResume = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(
            size * 0.25,
          ), // 25% of button size
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (isResume) {
                _downloadResume(context);
              } else {
                _launchUrl(url);
              }
            },
            borderRadius: BorderRadius.circular(size * 0.25),
            child: Icon(
              icon,
              color: color,
              size: size * 0.45, // 45% of button size for better proportions
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadResume(BuildContext context) async {
    // Replace YOUR_FILE_ID_HERE with your actual Google Drive file ID
    // https://drive.google.com/file/d/1qkOEUMjE8WPFKll52iv3dYRPADAndTao/view?usp=sharing
    const resumeUrl =
        'https://drive.google.com/uc?export=download&id=1qkOEUMjE8WPFKll52iv3dYRPADAndTao';

    try {
      final uri = Uri.parse(resumeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showSnackBar(context, 'Could not open resume link', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error downloading resume', isError: true);
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently in production
      debugPrint('Error launching URL: $e');
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFF424242) : const Color(0xFF2E2E2E),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
