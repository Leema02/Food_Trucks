import 'package:flutter/material.dart';

class DotColor {
  final Color dotPrimaryColor;
  final Color dotSecondaryColor;
  final Color dotThirdColor;
  final Color dotLastColor;

  const DotColor({
    required this.dotPrimaryColor,
    required this.dotSecondaryColor,
    required this.dotThirdColor,
    required this.dotLastColor,
  });

  Color get dotThirdColorReal => dotThirdColor;

  Color get dotLastColorReal => dotLastColor;
}

class LikeIcon extends Icon {
  final Color iconColor;

  const LikeIcon(
    IconData super.icon, {
    super.key,
    required this.iconColor,
  });

  @override
  Color get color => iconColor;
}

class OvershootCurve extends Curve {
  const OvershootCurve([this.period = 2.5]);

  final double period;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    t -= 1.0;
    return t * t * ((period + 1) * t + period) + 1.0;
  }

  @override
  String toString() {
    return '$runtimeType($period)';
  }
}
