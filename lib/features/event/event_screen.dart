// eventwelcome.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'create_event.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _textAnimation;

  final List<String> rotatingTexts = [
    "Discover Amazing Events",
    "Connect with Your Community",
    "Create Unforgettable Moments",
    "Join the Experience",
    "Your Event Journey Starts Here",
  ];

  int currentTextIndex = 0;

  final List<String> carouselImages = [
    "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80",
    "https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&q=80",
    "https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800&q=80",
    "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&q=80",
    "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=800&q=80",
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    // Auto-scroll carousel
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      int nextPage = _pageController.page!.round() + 1;
      if (nextPage >= carouselImages.length) nextPage = 0;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });

    // Rotating text animation
    _controller = AnimationController(
      duration: Duration(seconds: rotatingTexts.length * 3),
      vsync: this,
    )..repeat();

    _textAnimation = IntTween(begin: 0, end: rotatingTexts.length - 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _textAnimation.addListener(() {
      if (mounted) {
        setState(() {
          currentTextIndex = _textAnimation.value;
        });
      }
    });

    // Auto navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const CreateventPage(),
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top Half - Native Flutter Carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: carouselImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(carouselImages[index]),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Half - Welcome Text
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(255, 30, 109, 55), Color(0xFF16213e)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (_, opacity, __) => Opacity(
                      opacity: opacity,
                      child: const Text(
                        "Welcome to",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Events By Greyfundr",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.deepPurple,
                          offset: Offset(0, 0),
                        )
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      rotatingTexts[currentTextIndex],
                      key: ValueKey(currentTextIndex),
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 50),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    builder: (_, value, __) => Opacity(
                      opacity: value,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Taking you in",
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}