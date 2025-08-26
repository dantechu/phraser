import 'package:core/core.dart';
import 'package:flutter/material.dart';

class WaveLoadingWidget extends StatefulWidget {
  const WaveLoadingWidget({this.size, this.color});
  final double? size;
  final Color? color;
  @override
  State<WaveLoadingWidget> createState() => _WaveLoadingWidgetState();
}

class _WaveLoadingWidgetState extends State<WaveLoadingWidget> with TickerProviderStateMixin {
  late AnimationController _firstController;
  late AnimationController _secondController;
  late AnimationController _thirdController;
  late Animation<double> _firstAnimation;
  late Animation<double> _secondAnimation;
  late Animation<double> _thirdAnimation;
  final int _delayTime200 = 200;
  final int _delayTime400 = 400;

  @override
  void initState() {
    super.initState();
    _firstController = AnimationController(vsync: this, duration: Duration(milliseconds: _delayTime200));
    _secondController = AnimationController(vsync: this, duration: Duration(milliseconds: _delayTime200));
    _thirdController = AnimationController(vsync: this, duration: Duration(milliseconds: _delayTime200));
    _firstAnimation = Tween<double>(begin: 0, end: (widget.size ?? 19) + 3 / 2).animate(_firstController)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _secondAnimation = Tween<double>(begin: 0, end: (widget.size ?? 19) + 3 / 2).animate(_secondController)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    _thirdAnimation = Tween<double>(begin: 0, end: (widget.size ?? 19) + 3 / 2).animate(_thirdController)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        _firstController.repeat(reverse: true, period: Duration(milliseconds: _delayTime400));
        Future.delayed(Duration(milliseconds: _delayTime200), () {
          _secondController.repeat(reverse: true, period: Duration(milliseconds: _delayTime400));
        });

        Future.delayed(Duration(milliseconds: _delayTime400), () {
          _thirdController.repeat(reverse: true, period: Duration(milliseconds: _delayTime400));
        });
      } catch (e, s) {
        FirebaseCrashlytics.instance.log('$e-$s');
      }
    });
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    _thirdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _circleContainerWidget(_firstAnimation),
      SizedBox(width: ((widget.size ?? 20) ~/ 2).toDouble()),
      _circleContainerWidget(_secondAnimation),
      SizedBox(width: ((widget.size ?? 20) ~/ 2).toDouble()),
      _circleContainerWidget(_thirdAnimation),
    ]);
  }

  Widget _circleContainerWidget(Animation<double> animation) {
    return Transform.translate(
      offset: Offset(0, animation.value),
      child: Container(
        height: widget.size ?? 20,
        width: widget.size ?? 20,
        decoration: BoxDecoration(color: widget.color ?? const Color(0xFF0F7278), shape: BoxShape.circle),
      ),
    );
  }
}
