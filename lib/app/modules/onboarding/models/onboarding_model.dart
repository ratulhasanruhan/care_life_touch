/// Onboarding page model
class OnboardingPage {
  final String image;
  final String title;
  final String subtitle;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

/// Onboarding data
final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    image: 'assets/images/onboard_1.png',
    title: 'Trusted Medical Knowledge',
    subtitle: 'Access accurate, evidence based health information anytime, anywhere.',
  ),
  OnboardingPage(
    image: 'assets/images/onboard_2.png',
    title: 'Authentic Medicines Delivered',
    subtitle: 'Order verified medicines and healthcare products with secure, reliable delivery.',
  ),
  OnboardingPage(
    image: 'assets/images/onboard_3.png',
    title: 'Your Complete Health Platform',
    subtitle: 'Manage your health with trusted information and seamless medical shopping.',
  ),
];

