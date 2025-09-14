import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onCenterAction,
    this.backgroundColor = const Color(0xFF3F3B4A),
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0xFF9B97A0),
    this.height = 64,
    this.elevation = 8,
    this.iconSize = 43,
  });

  final int currentIndex;
  final void Function(int index) onTabSelected;
  final VoidCallback? onCenterAction;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final double height;
  final double elevation;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(asset: 'assets/images/Home.png'),
      _NavItem(asset: 'assets/images/List View.png'),
      _NavItem(asset: 'assets/images/Add.png', isCenter: true),
      _NavItem(asset: 'assets/images/Cash.png'),
      _NavItem(asset: 'assets/images/User Account.png'),
    ];

    return Material(
      color: backgroundColor,
      elevation: elevation,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final it = items[i];

              if (it.isCenter) {
                return _CenterActionButton(
                  asset: it.asset!,
                  size: iconSize,
                  onTap: onCenterAction,
                  bg: inactiveColor.withValues(alpha: .35),
                  tint: Colors.white.withValues(alpha: .9),
                );
              }

              final isActive = i == currentIndex;
              return _PngButton(
                asset: it.asset!,
                size: iconSize,
                color: isActive ? activeColor : inactiveColor,
                onTap: () => onTabSelected(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String? asset;
  final bool isCenter;
  _NavItem({this.asset, this.isCenter = false});
}

class _PngButton extends StatelessWidget {
  const _PngButton({
    required this.asset,
    required this.color,
    required this.onTap,
    required this.size,
  });

  final String asset;
  final Color color;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Image.asset(
          asset,
          width: size,
          height: size,
          color: color, // tint PNG to active/inactive color
        ),
      ),
    );
  }
}

class _CenterActionButton extends StatelessWidget {
  const _CenterActionButton({
    required this.asset,
    required this.size,
    required this.onTap,
    required this.bg,
    required this.tint,
  });

  final String asset;
  final double size;
  final VoidCallback? onTap;
  final Color bg;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 30,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Image.asset(asset, width: size, height: size, color: tint),
      ),
    );
  }
}
