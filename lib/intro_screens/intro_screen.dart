import 'package:flutter/material.dart';
import 'package:artist_hub/auth/login_screen.dart';
import 'package:artist_hub/shared/constants/app_colors.dart';
import 'package:artist_hub/shared/preferences/shared_preferences.dart';

import '../dashboards/artist_dashboard/artist_dashboard.dart';
import '../dashboards/customer_dashboard/customer_dashboard.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _iconScale = 1.0;
  bool _isAnimating = false;

  final List<IntroPage> _introPages = [
    IntroPage(
      title: 'Welcome to Artist Hub',
      description:
          'Connect with amazing artists from around the world and discover unique talents for your projects',
      image: '🎨',
      color: AppColors.purplePinkGradient,
      iconColor: Colors.purple,
      secondaryIcon: '🤝',
    ),
    IntroPage(
      title: 'Book Artists Instantly',
      description:
          'Easily browse, select and book artists for your events, projects, and creative needs',
      image: '👨‍🎨',
      color: AppColors.blueGradient,
      iconColor: Colors.blue,
      secondaryIcon: '📅',
    ),
    IntroPage(
      title: 'Showcase Your Talent',
      description:
          'Artists can build stunning portfolios, get discovered, and grow their creative careers',
      image: '🌟',
      color: AppColors.appBarGradient,
      iconColor: Colors.amber,
      secondaryIcon: '💼',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.init();

    // Animate the icon on first load
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _iconScale = 1.2;
        });
      }
    });
  }

  void _animateIcon() {
    if (_isAnimating) return;

    _isAnimating = true;
    setState(() {
      _iconScale = 1.3;
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _iconScale = 1.0;
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          _isAnimating = false;
        });
      }
    });
  }

  void _navigateToNextScreen() async {
    final isLoggedIn = SharedPreferencesHelper.isUserLoggedIn;
    final userType = SharedPreferencesHelper.userType;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => userType == 'artist'
              ? const ArtistDashboard()
              : const CustomerDashboard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skipIntro() async {
    await SharedPreferencesHelper.setFirstTime(false);
    _navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.loginBackgroundGradient.colors[0].withOpacity(0.95),
              AppColors.loginBackgroundGradient.colors[1].withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Animated background dots (remove on very small screens)
                if (!isVerySmallScreen) ...[
                  Positioned(
                    top: screenHeight * 0.1,
                    right: screenWidth * 0.1,
                    child: _buildAnimatedDot(Colors.white.withOpacity(0.1), 60),
                  ),
                  Positioned(
                    bottom: screenHeight * 0.2,
                    left: screenWidth * 0.1,
                    child: _buildAnimatedDot(
                      Colors.white.withOpacity(0.08),
                      40,
                    ),
                  ),
                ],

                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Skip button in top right
                    Container(
                      padding: EdgeInsets.only(
                        top:
                            MediaQuery.of(context).padding.top +
                            (isVerySmallScreen ? 10 : 20),
                        right: 16,
                      ),
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _skipIntro,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          padding: EdgeInsets.symmetric(
                            horizontal: isVerySmallScreen ? 12 : 16,
                            vertical: isVerySmallScreen ? 6 : 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: isVerySmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: isVerySmallScreen ? 14 : 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _introPages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                            _animateIcon();
                          });
                        },
                        itemBuilder: (context, index) {
                          return IntroPageWidget(
                            page: _introPages[index],
                            iconScale: _iconScale,
                            currentPage: _currentPage,
                            pageIndex: index,
                            isVerySmallScreen: isVerySmallScreen,
                          );
                        },
                      ),
                    ),

                    // Bottom section with indicators and button
                    Container(
                      padding: EdgeInsets.only(
                        bottom:
                            MediaQuery.of(context).padding.bottom +
                            (isVerySmallScreen ? 5 : 10),
                        left: 16,
                        right: 16,
                        top: isVerySmallScreen ? 8 : 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Custom animated indicators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _introPages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: _currentPage == index
                                    ? (isVerySmallScreen ? 16 : 20)
                                    : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: _currentPage == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                                  boxShadow: _currentPage == index
                                      ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isVerySmallScreen ? 10 : 15),

                          // Animated Get Started/Next button
                          SizedBox(
                            width: double.infinity,
                            height: isVerySmallScreen ? 44 : 50,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: _introPages[_currentPage]
                                        .color
                                        .colors[0]
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    if (_currentPage ==
                                        _introPages.length - 1) {
                                      await SharedPreferencesHelper.setFirstTime(
                                        false,
                                      );
                                      _navigateToNextScreen();
                                    } else {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Center(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        key: ValueKey(_currentPage),
                                        children: [
                                          Text(
                                            _currentPage ==
                                                    _introPages.length - 1
                                                ? 'Get Started'
                                                : 'Next',
                                            style: TextStyle(
                                              fontSize: isVerySmallScreen
                                                  ? 15
                                                  : 16,
                                              fontWeight: FontWeight.w700,
                                              color: _introPages[_currentPage]
                                                  .iconColor,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            _currentPage ==
                                                    _introPages.length - 1
                                                ? Icons.rocket_launch_rounded
                                                : Icons
                                                      .arrow_forward_ios_rounded,
                                            size: isVerySmallScreen ? 14 : 16,
                                            color: _introPages[_currentPage]
                                                .iconColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Optional: Quick skip text on last page (only for larger screens)
                          if (_currentPage == _introPages.length - 1 &&
                              !isVerySmallScreen &&
                              screenHeight > 650)
                            const SizedBox(height: 10),
                          if (_currentPage == _introPages.length - 1 &&
                              !isVerySmallScreen &&
                              screenHeight > 650)
                            GestureDetector(
                              onTap: _skipIntro,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  'Just explore the app →',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedDot(Color color, double size) {
    return AnimatedContainer(
      duration: const Duration(seconds: 4),
      curve: Curves.easeInOut,
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class IntroPage {
  final String title;
  final String description;
  final String image;
  final LinearGradient color;
  final Color iconColor;
  final String secondaryIcon;

  IntroPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.iconColor,
    this.secondaryIcon = '✨',
  });
}

class IntroPageWidget extends StatelessWidget {
  final IntroPage page;
  final double iconScale;
  final int currentPage;
  final int pageIndex;
  final bool isVerySmallScreen;

  const IntroPageWidget({
    super.key,
    required this.page,
    required this.iconScale,
    required this.currentPage,
    required this.pageIndex,
    required this.isVerySmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isActive = currentPage == pageIndex;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with floating effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect (remove on very small screens)
                if (!isVerySmallScreen)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: isVerySmallScreen ? 120 : 150,
                    height: isVerySmallScreen ? 120 : 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          page.color.colors[0].withOpacity(0.3),
                          page.color.colors[1].withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.1, 0.3, 1.0],
                      ),
                    ),
                  ),

                // Main icon container
                AnimatedScale(
                  scale: isActive ? iconScale : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Container(
                    width: isVerySmallScreen ? 100 : 130,
                    height: isVerySmallScreen ? 100 : 130,
                    decoration: BoxDecoration(
                      gradient: page.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: page.color.colors[0].withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: page.color.colors[1].withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        page.image,
                        style: TextStyle(fontSize: isVerySmallScreen ? 40 : 50),
                      ),
                    ),
                  ),
                ),

                // Floating secondary icon (remove on very small screens)
                if (!isVerySmallScreen)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Text(
                        page.secondaryIcon,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: isVerySmallScreen ? 20 : 30),

            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: isActive ? 1.0 : 0.3,
              child: Text(
                page.title,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 22 : 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: isVerySmallScreen ? 12 : 16),

            // Description with smooth animation
            AnimatedPadding(
              duration: const Duration(milliseconds: 400),
              padding: EdgeInsets.symmetric(horizontal: isActive ? 16 : 24),
              child: Text(
                page.description,
                style: TextStyle(
                  fontSize: isVerySmallScreen ? 14 : 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            if (isActive && !isVerySmallScreen)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  '${pageIndex + 1}/${3}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
