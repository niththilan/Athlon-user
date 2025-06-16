// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(AthlonApp());
}

class AthlonApp extends StatelessWidget {
  const AthlonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Athlon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0A1E3C), // Navy blue
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeInAnimation;

  String _displayedText = "";
  final String _fullText = "ATHLON";
  int _currentIndex = 0;
  late Timer _typingTimer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();

    // Start typing animation after logo animation completes
    Timer(Duration(milliseconds: 1600), () {
      _startTypingAnimation();
    });

    // Navigate to home screen after animations complete
    //Timer(Duration(seconds: 4), () {
    //Navigator.of(context).pushReplacement(
    //MaterialPageRoute(builder: (context) => HomeScreen()),
    //);
    //});
  }

  void _startTypingAnimation() {
    _typingTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      setState(() {
        if (_currentIndex < _fullText.length) {
          _displayedText = _fullText.substring(0, _currentIndex + 1);
          _currentIndex++;
        } else {
          _typingTimer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    if (_typingTimer.isActive) {
      _typingTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1E3C), // Navy blue background
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: NewLogoWidget(),
                ),
                SizedBox(height: 30),
                Text(
                  _displayedText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 10),
                Opacity(
                  opacity: _fadeInAnimation.value,
                  child: Text(
                    'BOOK YOUR SPORTS COMPLEX',
                    style: TextStyle(
                      color: Color(0xFFADBBCC), // Light grey
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NewLogoWidget extends StatelessWidget {
  const NewLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(size: Size(90, 90), painter: NewLogoPainter()),
      ),
    );
  }
}

class NewLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2.5;

    // Main circular background
    final Paint bgPaint = Paint()
      ..color = Color(0xFF0A1E3C)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);

    // Sports elements
    final Paint elementPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw a basketball-like pattern
    for (int i = 0; i < 4; i++) {
      double angle = i * math.pi / 2;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 0.8),
        angle,
        math.pi / 2,
        false,
        elementPaint,
      );
    }

    // Crossing lines like a basketball
    canvas.drawLine(
      Offset(centerX - radius * 0.8, centerY),
      Offset(centerX + radius * 0.8, centerY),
      elementPaint,
    );

    canvas.drawLine(
      Offset(centerX, centerY - radius * 0.8),
      Offset(centerX, centerY + radius * 0.8),
      elementPaint,
    );

    // Sports field markings
    final Paint detailPaint = Paint()
      ..color = Color(0xFF78A1BB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw a small circle in the center (like center court)
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.3, detailPaint);

    // Draw small arcs representing court boundaries
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 0.6),
      math.pi * 0.25,
      math.pi * 0.5,
      false,
      detailPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 0.6),
      math.pi * 1.25,
      math.pi * 0.5,
      false,
      detailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldPainter) {
    return true;
  }
}

// Placeholder for the home screen
//class HomeScreen extends StatelessWidget {
  //@override
  //Widget build(BuildContext context) {
    //return Scaffold(
      //appBar: AppBar(
        //title: Text('Athlon'),
        //backgroundColor: Color(0xFF0A1E3C),
      //),
      //body: Center(
        //child: Text('Welcome to Athlon App!'),
      //),
    //);
  //}
//}
