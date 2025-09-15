import 'package:flutter/material.dart';

enum DrawerState { opening, closing, open, closed }

enum StyleState {
  overlay,
  fixedStack,
  stack,
  scaleRight,
  scaleBottom,
  scaleTop,
  scaleRotate,
  rotate3dIn,
  rotate3dOut,
  popUp,
}

class AwesomeDrawerBarController {
  Function? open;
  Function? close;
  Function? toggle;
  Function? isOpen;
  ValueNotifier<DrawerState>? stateNotifier;
}

class AwesomeDrawerBar extends StatefulWidget {
  final StyleState type;
  final AwesomeDrawerBarController? controller;
  final Widget menuScreen;
  final Widget mainScreen;
  final Widget? otherScreens;  // <--- Add this field
  final double? slideWidth;
  final double borderRadius;
  final double angle;
  final Color backgroundColor;
  final bool showShadow;
  final bool disableOnCickOnMainScreen;

  const AwesomeDrawerBar({
    Key? key,
    this.type = StyleState.overlay,
    this.controller,
    required this.menuScreen,
    required this.mainScreen,
    this.otherScreens,  // <--- optional parameter
    this.slideWidth,
    this.borderRadius = 16.0,
    this.angle = 0.0,
    this.backgroundColor = Colors.white,
    this.showShadow = false,
    this.disableOnCickOnMainScreen = false,
  }) : super(key: key);

  @override
  _AwesomeDrawerBarState createState() => _AwesomeDrawerBarState();
}

class _AwesomeDrawerBarState extends State<AwesomeDrawerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  DrawerState _state = DrawerState.closed;
  ValueNotifier<DrawerState>? stateNotifier;

  @override
  void initState() {
    super.initState();

    stateNotifier = ValueNotifier(_state);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        switch (status) {
          case AnimationStatus.forward:
            _state = DrawerState.opening;
            break;
          case AnimationStatus.reverse:
            _state = DrawerState.closing;
            break;
          case AnimationStatus.completed:
            _state = DrawerState.open;
            break;
          case AnimationStatus.dismissed:
            _state = DrawerState.closed;
            break;
        }
        stateNotifier!.value = _state;
      });

    if (widget.controller != null) {
      widget.controller!.open = () => _animationController.forward();
      widget.controller!.close = () => _animationController.reverse();
      widget.controller!.toggle = () =>
          (_state == DrawerState.open) ? _animationController.reverse() : _animationController.forward();
      widget.controller!.isOpen = () => _state == DrawerState.open;
      widget.controller!.stateNotifier = stateNotifier;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildDrawerLayout() {
    double screenWidth = MediaQuery.of(context).size.width;
    double drawerWidth = widget.slideWidth ?? screenWidth * 0.75;

    return Stack(
      children: [
        if (widget.otherScreens != null) widget.otherScreens!,

        widget.menuScreen,

        AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) {
            double slide = drawerWidth * _animationController.value;
            double scale = 1 - (_animationController.value * 0.2);
            double angle = 0;

            return Transform(
              transform: Matrix4.identity()
                ..translate(slide)
                ..scale(scale)
                ..rotateZ(angle),
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(widget.borderRadius * _animationController.value),
                child: GestureDetector(
                  onTap: () {
                    if (_state == DrawerState.open) {
                      _animationController.reverse();
                    }
                  },
                  child: Stack(
                    children: [
                      AbsorbPointer(
                        absorbing:
                            _animationController.value > 0 && widget.disableOnCickOnMainScreen,
                        child: widget.mainScreen,
                      ),
                      if (_animationController.value > 0)
                        Container(color: Colors.black.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildDrawerLayout();
  }
}
