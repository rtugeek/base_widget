import 'dart:math';

import 'package:flutter/material.dart';
import 'package:base_widget/generated/assets.dart';

class ClockWidget extends StatefulWidget {
  final double size;
  final double borderRadius;
  final double padding;

  const ClockWidget(
      {Key? key,
      required this.size,
      required this.borderRadius,
      required this.padding})
      : super(key: key);

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget>
    with TickerProviderStateMixin {
  var _currentSecond = 0;
  //1°
  final double _degree1 = pi / 180;

  late AnimationController _secondAnimationController;
  late AnimationController _minuteAnimationController;
  late AnimationController _hourAnimationController;

  _ClockWidgetState() {}
  static const Duration startDuration = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    _secondAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 60);
    _minuteAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 60);
    _hourAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 12);
    _secondAnimationController.animateTo(now.second.toDouble(),
        curve: Curves.easeOutQuart, duration: startDuration);

    _secondAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _secondAnimationController.repeat(
            min: 0, max: 60, period: const Duration(minutes: 1));
      }
    });

    _minuteAnimationController.animateTo(now.minute.toDouble(),
        curve: Curves.easeOutQuart,
        duration: const Duration(milliseconds: 1000));
    _hourAnimationController.animateTo(now.hour.toDouble() % 12,
        curve: Curves.easeOutQuart,
        duration: const Duration(milliseconds: 1200));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
          color: const Color(0xff292727),
          borderRadius: BorderRadius.circular(widget.borderRadius)),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.size)),
          ),
          Image.asset(
            Assets.imagesClockBg,
            package: "base_widget",
          ),
          buildClockHand(Assets.imagesClockHandHour, _hourAnimationController),
          buildClockHand(
              Assets.imagesClockHandMinute, _minuteAnimationController),
          buildClockHand(
              Assets.imagesClockHandSecond, _secondAnimationController,
              onBuild: () {
            var currentSecond = _secondAnimationController.value.toInt();
            //每转一圈，更新分钟和时钟信息
            if (currentSecond == 0) {
              //防止重复触发
              if (_currentSecond != 0) {
                _currentSecond == 0;
                updateHourAndMinute();
              }
            } else {
              _currentSecond = currentSecond;
            }
          })
        ],
      ),
    );
  }

  /// 生成指针
  /// - imageAsset: 指针图片
  /// - controller: 动画控制器
  Widget buildClockHand(String imageAsset, AnimationController controller,
      {Function? onBuild}) {
    return AnimatedBuilder(
      animation: _secondAnimationController,
      builder: (context, child) {
        onBuild?.call();
        return Transform.rotate(
            angle: getAngle(controller.value / controller.upperBound * 360),
            child: child);
      },
      child: Image.asset(imageAsset, package: "base_widget"),
    );
  }

  void updateHourAndMinute() async {
    var now = DateTime.now();
    _minuteAnimationController.animateTo(now.minute.toDouble(),
        curve: Curves.easeOutQuart, duration: startDuration);
    _hourAnimationController.animateTo(now.hour % 12.toDouble(),
        curve: Curves.easeOutQuart, duration: startDuration);
  }

  /// 角度转弧度
  double getAngle(double degree) {
    return _degree1 * degree;
  }

  @override
  void dispose() {
    _secondAnimationController.dispose();
    _minuteAnimationController.dispose();
    _hourAnimationController.dispose();
    super.dispose();
  }
}
