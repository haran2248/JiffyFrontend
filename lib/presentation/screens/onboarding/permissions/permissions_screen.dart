import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/navigation/app_routes.dart';
import '../../../widgets/button.dart';
import '../../../widgets/progress_bar.dart';
import 'viewmodels/permissions_viewmodel.dart';
import 'models/permissions_state.dart';
import 'widgets/permission_card.dart';

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(permissionsViewModelProvider);
    final state = stateAsync.when(
      data: (data) => data,
      loading: () => const PermissionsState(),
      error: (_, __) => const PermissionsState(),
    );
    final viewModel = ref.read(permissionsViewModelProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Permissions"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Setup Progress",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text(
                "1/4",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const ProgressBar(currentStep: 1, totalSteps: 4),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Just a couple of things...",
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "To give you the best experience, we need a few permissions.",
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PermissionCard(
                      icon: Icons.location_on_outlined,
                      title: "Enable Location",
                      description:
                          "Discover matches nearby and see distances to profiles",
                      isGranted: state.locationGranted,
                      onTap: viewModel.requestLocation,
                    ),
                    const SizedBox(height: 16),
                    PermissionCard(
                      icon: Icons.notifications_none_outlined,
                      title: "Push Notifications",
                      description:
                          "Stay up to date when new matches or messages come in",
                      isGranted: state.notificationsGranted,
                      onTap: viewModel.requestNotifications,
                    ),
                    const SizedBox(height: 16),
                    PermissionCard(
                      icon: Icons.camera_alt_outlined,
                      title: "Camera",
                      description:
                          "Take photos directly with your camera for your profile",
                      isGranted: state.cameraGranted,
                      onTap: viewModel.requestCamera,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Consumer(
                  builder: (context, ref, _) {
                    final stateAsync = ref.watch(permissionsViewModelProvider);
                    final currentState = stateAsync.when(
                      data: (data) => data,
                      loading: () => const PermissionsState(),
                      error: (_, __) => const PermissionsState(),
                    );
                    
                    // Block continue until all required permissions are granted
                    // Location and notifications are required, photo library and camera are optional
                    final canContinue = currentState.locationGranted && 
                                       currentState.notificationsGranted;
                    
                    return Opacity(
                      opacity: canContinue ? 1.0 : 0.5,
                      child: AbsorbPointer(
                        absorbing: !canContinue,
                        child: Button(
                          text: "Continue",
                          onTap: () {
                            // Navigate to curated profile screen after permissions
                            context.goToRoute(AppRoutes.profileCurated);
                          },
                        ),
                      ),
                    );
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
