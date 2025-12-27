import 'package:flutter/material.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';

/// Bottom navigation bar for main app navigation
class BottomNavigationBarWidget extends StatelessWidget {
  final String currentRoute;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentRoute == AppRoutes.home,
                onTap: () => context.goToRoute(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: 'Discover',
                isActive: false, // TODO: Update when discover route is added
                onTap: () {
                  // TODO: Navigate to discover
                },
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Chats',
                isActive: false, // TODO: Update when chats route is added
                onTap: () {
                  // TODO: Navigate to chats
                },
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: false, // TODO: Update when profile route is added
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

