import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    required this.currentIndex,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main content
          child,

          // Floating navigation bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.add_circle_outline,
                      activeIcon: Icons.add_circle,
                      label: 'Report',
                      index: 1,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.feed_outlined,
                      activeIcon: Icons.feed_rounded,
                      label: 'Feed',
                      index: 2,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person_rounded,
                      label: 'Profile',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF2D6A4F) : Colors.grey.shade400;

    return Expanded(
      child: InkWell(
        onTap: () {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/report');
              break;
            case 2:
              context.go('/feed');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
