// ignore: file_names
import 'package:flutter/material.dart';
import 'model.dart';
import 'dot_painter.dart';
import 'circle_painter.dart';

typedef LikeCallback = void Function(bool isLike);

class LikeButton extends StatefulWidget {
  final double width;
  final LikeIcon icon;
  final Duration duration;
  final DotColor dotColor;
  final Color circleStartColor;
  final Color circleEndColor;
  final LikeCallback onIconClicked;

  const LikeButton({
    required Key key,
    required this.width,
    this.icon = const LikeIcon(
      Icons.favorite,
      iconColor: Colors.red,
    ),
    this.duration = const Duration(milliseconds: 1000),
    this.dotColor = const DotColor(
      dotPrimaryColor: Color(0xFFFFC107),
      dotSecondaryColor: Color(0xFFFF9800),
      dotThirdColor: Color(0xFFFF5722),
      dotLastColor: Color(0xFFF44336),
    ),
    this.circleStartColor = const Color(0xFFFF5722),
    this.circleEndColor = const Color(0xFFFFC107),
    required this.onIconClicked,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> outerCircle;
  late Animation<double> innerCircle;
  late Animation<double> scale;
  late Animation<double> dots;

  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..addListener(() {
        setState(() {});
      });
    _initAllAmimations();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CustomPaint(
          size: Size(widget.width, widget.width),
          painter: DotPainter(
            currentProgress: dots.value,
            color1: widget.dotColor.dotPrimaryColor,
            color2: widget.dotColor.dotSecondaryColor,
            color3: widget.dotColor.dotThirdColorReal,
            color4: widget.dotColor.dotLastColorReal,
          ),
        ),
        CustomPaint(
          size: Size(widget.width * 0.35, widget.width * 0.35),
          painter: CirclePainter(
              innerCircleRadiusProgress: innerCircle.value,
              outerCircleRadiusProgress: outerCircle.value,
              startColor: widget.circleStartColor,
              endColor: widget.circleEndColor),
        ),
        Container(
          width: widget.width,
          height: widget.width,
          alignment: Alignment.center,
          child: Transform.scale(
            scale: isLiked ? scale.value : 1.0,
            child: GestureDetector(
              onTap: _onTap,
              child: Icon(
                widget.icon.icon,
                color: isLiked ? widget.icon.color : Colors.white,
                size: widget.width * 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTap() {
    if (_controller.isAnimating) return;
    isLiked = !isLiked;
    if (isLiked) {
      _controller.reset();
      _controller.forward();
    } else {
      setState(() {});
    }
    widget.onIconClicked(isLiked);
  }

  void _initAllAmimations() {
    outerCircle = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.0,
          0.3,
          curve: Curves.ease,
        ),
      ),
    );
    innerCircle = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.2,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );
    scale = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.35,
          0.7,
          curve: OvershootCurve(),
        ),
      ),
    );
    dots = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1,
          1.0,
          curve: Curves.decelerate,
        ),
      ),
    );
  }
}
