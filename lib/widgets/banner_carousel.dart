import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BannerCarousel extends StatefulWidget {
  final VoidCallback? onBannerTap;

  const BannerCarousel({
    super.key,
    this.onBannerTap,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'Autumn Mega Sale',
      'subtitle': 'Up to 50% OFF on Audio & Wearables',
      'code': 'USE CODE AURA50',
      'tag': 'FLASH DEAL',
      'color1': '0xFF4338CA',
      'color2': '0xFF6366F1',
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Curated handcrafted fashion & apparel',
      'code': 'EXTRA 20% WITH SAVE20',
      'tag': 'TRENDING',
      'color1': '0xFFE11D48',
      'color2': '0xFFFB7185',
    },
    {
      'title': 'Nordic Living',
      'subtitle': 'Elevate your everyday interior aesthetic',
      'code': 'FREE SHIPPING \$100+',
      'tag': 'FEATURED',
      'color1': '0xFF0D9488',
      'color2': '0xFF14B8A6',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 184,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              final c1 = Color(int.parse(banner['color1']!));
              final c2 = Color(int.parse(banner['color2']!));

              return GestureDetector(
                onTap: () {
                  if (widget.onBannerTap != null) {
                    widget.onBannerTap!();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                  gradient: LinearGradient(
                    colors: [c1, c2],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c1.withAlpha(90),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppStyles.radiusLg),
                  child: Stack(
                    children: [
                      // Decorative background spheres
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(20),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -40,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(15),
                          ),
                        ),
                      ),

                      // Banner Content
                      Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(45),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    banner['tag']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: TextStyle(
                                color: Colors.white.withAlpha(235),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                banner['code']!,
                                style: const TextStyle(
                                  color: AppColors.accentLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          ),
        ),
        const SizedBox(height: 12),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 24 : 7,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.primary
                    : Colors.grey.shade400.withAlpha(120),
                borderRadius: BorderRadius.circular(6),
                boxShadow: _currentIndex == index
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
