import 'package:flutter/material.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/presentation/widgets/button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FirstTimeStoryPromptSheet extends StatelessWidget {
  final BuildContext parentContext;

  const FirstTimeStoryPromptSheet({super.key, required this.parentContext});

  static Future<void> show(BuildContext context) {
    final parentCtx = context;
    return showModalBottomSheet<void>(
      context: parentCtx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FirstTimeStoryPromptSheet(parentContext: parentCtx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.cameraRetro,
                  size: 32,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Stand Out Faster!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Posting a story increases your visibility and chances of match by 80%.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Button(
                  text: 'Let\'s do it',
                  type: ButtonType.primary,
                  onTap: () {
                    // Close the sheet
                    Navigator.of(context).pop();
                    // Navigate to story creation using stable parent context
                    if (parentContext.mounted) {
                      parentContext.pushRoute(AppRoutes.storyCreation);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Button(
                  text: 'Maybe later',
                  type: ButtonType.ghost,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
