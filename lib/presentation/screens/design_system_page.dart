import 'package:flutter/material.dart' hide Card, Chip;
import '../../core/theme/app_colors.dart';
import '../widgets/button.dart';
import '../widgets/card.dart';
import '../widgets/input.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chip.dart';
import '../widgets/avatar.dart';

class DesignSystemPage extends StatelessWidget {
  const DesignSystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modern Electric System")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, "Typography"),
            Text("Display Large",
                style: Theme.of(context).textTheme.displayLarge),
            Text("Display Medium",
                style: Theme.of(context).textTheme.displayMedium),
            Text("Body Large", style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Rich Premium Palette"),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorSwatch(
                    context, "Raspberry", AppColors.primaryRaspberry),
                _buildColorSwatch(context, "Violet", AppColors.primaryViolet),
                _buildColorSwatch(
                    context, "Midnight Plum", AppColors.midnightPlum),
                _buildColorSwatch(context, "Noir", AppColors.noir),
                _buildColorSwatch(
                    context, "Surface Plum", AppColors.surfacePlum),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Buttons"),
            Button(text: "Primary Action", onTap: () {}),
            const SizedBox(height: 12),
            Button(
                text: "Secondary Action",
                type: ButtonType.secondary,
                onTap: () {}),
            const SizedBox(height: 12),
            Button(text: "Ghost Action", type: ButtonType.ghost, onTap: () {}),
            const SizedBox(height: 12),
            // Button(text: "Loading...", isLoading: true, onTap: () {}),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Inputs"),
            const Input(label: "Username", placeholder: "cool_user_99"),
            const SizedBox(height: 16),
            const Input(
                label: "Password", placeholder: "•••••••", obscureText: true),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Onboarding Components"),
            const Text("Avatar"),
            const SizedBox(height: 8),
            const Row(
              children: [
                Avatar(radius: 40),
                SizedBox(width: 16),
                Avatar(radius: 30),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Chat Bubbles"),
            const SizedBox(height: 8),
            const ChatBubble(text: "Hey! I'm your AI assistant.", isMe: false),
            const ChatBubble(
                text: "That sounds awesome! Let's go.", isMe: true),
            const SizedBox(height: 24),
            const Text("Selection Chips"),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              children: [
                Chip(label: "Photography", isSelected: false),
                Chip(label: "Hiking", isSelected: true),
                Chip(label: "Coding", isSelected: false),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Cards"),
            Card(
              child: Column(
                children: [
                  Row(children: [
                    const Icon(Icons.bolt, color: AppColors.primaryViolet),
                    const SizedBox(width: 8),
                    Text("Electric Card",
                        style: Theme.of(context).textTheme.labelLarge),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    "A sleek glassmorphic card with electric accents. Perfect for a premium yet fun vibe.",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryRaspberry,
              letterSpacing: 1.5,
            ),
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, String name, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
