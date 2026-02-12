import 'package:flutter/material.dart';
import 'package:dihaadi_app/constants/colors.dart';

class DotPattern extends StatelessWidget {
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  const DotPattern({
    super.key,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (topLeft)
          Positioned(
            top: 40,
            left: 20,
            child: _buildDotGrid(),
          ),
        if (topRight)
          Positioned(
            top: 40,
            right: 20,
            child: _buildDotGrid(),
          ),
        if (bottomLeft)
          Positioned(
            bottom: 40,
            left: 20,
            child: _buildDotGrid(),
          ),
        if (bottomRight)
          Positioned(
            bottom: 40,
            right: 20,
            child: _buildDotGrid(),
          ),
      ],
    );
  }

  Widget _buildDotGrid() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: _DotGridPainter(),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    const dotRadius = 2.0;
    const spacing = 8.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
