import 'package:flutter/material.dart';

class BouncingContainer extends StatefulWidget {
  static GlobalKey<_BouncingContainerState> bouncingGlobalKey = GlobalKey(
      debugLabel: '[clase BouncingContainer] _BouncingContainerState Key');
  static BouncingContainer miAlarmita = BouncingContainer(
    key: bouncingGlobalKey,
  );
  // static GlobalKey<_BouncingContainerState> globalKey = GlobalKey(
  //     debugLabel: '[clase BouncingContainer] _BouncingContainerState Key');

  BouncingContainer({key}) : super(key: key);
  // BouncingContainer({globalKey}) : super(key: globalKey);

  @override
  _BouncingContainerState createState() => _BouncingContainerState();

  void bounce() async {
    print("[LiveNotification] me muevo!");
    bouncingGlobalKey.currentState?.bounce();
  }
}

class _BouncingContainerState extends State<BouncingContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 600),
    vsync: this,
  );

  late final Animation<double> _animation = Tween(begin: 0.0, end: -.15)
      .chain(CurveTween(curve: Curves.elasticIn))
      .animate(_controller);

  void _runAnimation() async {
    for (int i = 0; i < 3; i++) {
      await _controller.forward();
      await _controller.reverse();
    }
  }

  void bounce() async {
    print("[LiveNotification] me muevo!");
    _runAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: Container(
        child: const Icon(
          Icons.notifications,
          size: 34,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _controller.dispose();

    super.dispose();
  }
}
