import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _prefsKey = 'onboarding_v2_completed';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingContent(
      imageAsset: 'assets/images/onboarding_car_health.png',
      title: "Know Your Car's Health",
      body:
          'Track your vehicle details, maintenance status, and upcoming services all in one place — no more guesswork.',
    ),
    _OnboardingContent(
      imageAsset: 'assets/images/onboarding_maintenance.png',
      title: 'Never Miss Maintenance',
      body:
          'Get timely reminders for oil changes, tire checks, and services so your car stays reliable and safe.',
    ),
    _OnboardingContent(
      imageAsset: 'assets/images/onboarding_help.png',
      title: 'Find Help When You Need It',
      body:
          'Locate nearby garages, book services, or request onsite assistance anytime, anywhere.',
    ),
    _OnboardingContent(
      imageAsset: 'assets/images/onboarding_ai_assistant.png',
      title: 'Ask Your AI Car Assistant',
      body:
          'Chat with an AI assistant for instant help, maintenance tips, and answers about your vehicle.',
    ),
    _OnboardingContent(
      imageAsset: 'assets/images/onboarding_learn_share.png',
      title: 'Learn. Share. Drive Better.',
      body:
          'Explore car care guides and connect with other drivers to share experiences and advice.',
    ),
    _OnboardingContent(
      title: 'Ready to Drive Smarter?',
      body:
          'Join thousands of drivers who trust us to keep their vehicles in perfect condition.',
    ),
  ];

  Future<void> _setCompletedAndContinue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    if (!mounted) return;
    _goToApp();
  }

  void _goToApp() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _onNext() {
    if (_currentPage == _pages.length - 1) {
      _setCompletedAndContinue();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSkip() {
    _setCompletedAndContinue();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _PageDots(count: _pages.length, index: _currentPage),
                  const Spacer(),
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        if (page.imageAsset.isNotEmpty)
                          SizedBox(
                            height: 260,
                            child: Image.asset(
                              page.imageAsset,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(height: 24),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _onNext,
                  child: Text(isLast ? 'Get Started' : 'Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    this.imageAsset = '',
    required this.title,
    required this.body,
  });

  final String imageAsset;
  final String title;
  final String body;
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
