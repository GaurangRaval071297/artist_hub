import 'package:flutter/material.dart';
import 'package:artist_hub/Constants/app_colors.dart';
import 'package:artist_hub/Screen/Shared Preference/shared_pref.dart';

import '../Splash Screen/splash_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<IntroductionPage> _pages = [
    IntroductionPage(
      title: "Welcome to Artist Hub",
      description: "Discover amazing artists and connect with creative minds from around the world.",
      image: Icons.brush,
      color: Colors.deepPurple,
    ),
    IntroductionPage(
      title: "Showcase Your Art",
      description: "Display your artwork, reach potential buyers, and grow your artistic career.",
      image: Icons.palette,
      color: Colors.pink,
    ),
    IntroductionPage(
      title: "Connect & Collaborate",
      description: "Find clients, collaborate with other artists, and join creative communities.",
      image: Icons.people,
      color: Colors.blue,
    ),
    IntroductionPage(
      title: "Get Started",
      description: "Join thousands of artists and art enthusiasts in our vibrant community.",
      image: Icons.rocket_launch,
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeIntroduction() async {
    // Mark first launch as completed
    await SharedPreferencesService.completeFirstLaunch();

    // Navigate to splash screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeIntroduction,
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page);
                },
              ),
            ),

            // Page Indicator and Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                          (index) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primaryColor
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Next/Get Started Button
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.appBarGradient.colors[0].withOpacity(0.9),
                          AppColors.appBarGradient.colors[1].withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeIntroduction();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildPage(IntroductionPage page) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image/Icon
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  page.color.withOpacity(0.1),
                  page.color.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              page.image,
              size: 100,
              color: page.color,
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class IntroductionPage {
  final String title;
  final String description;
  final IconData image;
  final Color color;

  IntroductionPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}