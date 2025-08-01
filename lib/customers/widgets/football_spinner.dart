import 'package:flutter/material.dart';

class FootballSpinner extends StatefulWidget {
  final double size;
  final Color color;

  const FootballSpinner({
    Key? key,
    this.size = 40.0,
    this.color = const Color(0xFF1B2C4F),
  }) : super(key: key);

  @override
  State<FootballSpinner> createState() => _FootballSpinnerState();
}

class _FootballSpinnerState extends State<FootballSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        child: Icon(
          Icons.sports_soccer,
          color: widget.color,
          size: widget.size * 0.75,
        ),
      ),
    );
  }
}

// Loading widget with ball spinner
class FootballLoadingWidget extends StatelessWidget {
  final Color? backgroundColor;

  const FootballLoadingWidget({
    Key? key,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor ?? const Color(0xFFF5F6FA),
      child: const Center(
        child: FootballSpinner(size: 60.0),
      ),
    );
  }
}
