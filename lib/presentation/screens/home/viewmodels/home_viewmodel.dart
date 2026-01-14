import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/presentation/screens/home/models/home_data.dart';
import 'package:jiffy/presentation/screens/home/models/suggestion_candidate.dart';
import 'package:jiffy/core/auth/auth_repository.dart';

part 'home_viewmodel.g.dart';

/// ViewModel state for home screen
class HomeState {
  final HomeData? data;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    HomeData? data,
    bool? isLoading,
    String? Function()? error,
  }) {
    return HomeState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ViewModel for home screen
@riverpod
class HomeViewModel extends _$HomeViewModel {
  @override
  HomeState build() {
    // Load data on initialization after build completes
    Future.microtask(() => loadHomeData());
    return const HomeState(isLoading: true);
  }

  /// Load home screen data from service
  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final homeService = ref.read(homeServiceProvider);
      final authRepo = ref.read(authRepositoryProvider);

      // 1. Fetch base home data (stories, trending, prompts)
      var data = await homeService.fetchHomeData();

      // ROTATING PROMPTS LOGIC
      final List<String> promptTexts = [
        "What's the most adventurous thing you've ever done?",
        "If you could have dinner with anyone, who would it be?",
        "What's your biggest pet peeve?",
        "Describe your perfect Sunday.",
      ];
      final randomPrompt =
          promptTexts[DateTime.now().millisecond % promptTexts.length];

      // Override the prompt with a random one
      data = data.copyWith(
        currentPrompt: () => MatchPrompt(
          id: data.currentPrompt?.id ?? 'rotating_prompt',
          promptText: randomPrompt,
          isNew: true,
          createdAt: DateTime.now(),
        ),
      );

      // 2. Fetch suggestions (Direct API call)
      List<SuggestionCard> suggestions = [];

      if (authRepo.currentUser != null) {
        try {
          final userId = authRepo.currentUser!.uid;
          final response = await homeService.fetchSuggestions(userId);

          // Map response to UI cards
          suggestions = response.candidates.map((candidate) {
            // Parse age safely (handle int or String from backend)
            int age = 25;
            if (candidate.age is int) {
              age = candidate.age;
            } else if (candidate.age is String) {
              age = int.tryParse(candidate.age) ?? 25;
            }

            return SuggestionCard(
              id: candidate.candidateUserId,
              userId: candidate.candidateUserId,
              name: candidate.name ?? _mockNameForId(candidate.candidateUserId),
              age: age,
              // Legacy support: Use first image if available
              imageUrl:
                  (candidate.imageUrl != null && candidate.imageUrl!.isNotEmpty)
                      ? candidate.imageUrl!.first
                      : null,
              imageUrls: candidate.imageUrl ?? [],
              bio: candidate.matchReason,
              relationshipPreview: candidate.matchReason,
              isTopPick: candidate.bucket == BucketType.topPick,
              distanceKm: candidate.distanceKm,
            );
          }).toList();
        } catch (e) {
          print('Error fetching suggestions: $e');
        }
      }

      // 3. Fetch matches (Reuse logic from Matches repo)
      List<SuggestionCard> matches = [];
      if (authRepo.currentUser != null) {
        try {
          final userId = authRepo.currentUser!.uid;
          final matchesJson = await homeService.fetchMatches(userId);

          // Map matches to SuggestionCards
          matches = matchesJson.map((json) {
            // Robust parsing for matches JSON
            // Assuming fields: uid/id, name, age, imageUrl/image_url, etc.
            final id = json['uid'] as String? ?? json['id'] as String? ?? '';
            final name = json['name'] as String? ?? 'User';
            final ageVal = json['age'];
            int age = 25;
            if (ageVal is int) age = ageVal;
            if (ageVal is String) age = int.tryParse(ageVal) ?? 25;

            // Handle images by constructing URL from ID (like MatchesViewModel)
            List<String> imgs = [];
            final constructedUrl = _constructMatchImageUrl(json);

            if (constructedUrl != null) {
              imgs.add(constructedUrl);
            } else {
              // Fallback: Check for direct URLs if backend sends them
              final imgUrl =
                  json['imageUrl'] as String? ?? json['image_url'] as String?;
              if (imgUrl != null && imgUrl.isNotEmpty) {
                imgs.add(imgUrl);
              }
            }

            // Check for list of images if available (fallback)
            if (imgs.isEmpty && json['imageUrls'] is List) {
              imgs.addAll((json['imageUrls'] as List)
                  .map((e) => e.toString())
                  .toList());
            }

            return SuggestionCard(
              id: id,
              userId: id,
              name: name,
              age: age,
              imageUrl: imgs.isNotEmpty ? imgs.first : null,
              imageUrls: imgs,
              bio: json['bio'] as String? ??
                  '', // Matches might not have bio in summary
              relationshipPreview:
                  json['matchReason'] as String? ?? 'Matched', // Failover text
              isTopPick: false,
            );
          }).toList();
        } catch (e) {
          print('Error fetching matches: $e');
        }
      }

      // Merge suggestions and matches into HomeData
      data = data.copyWith(
        suggestions: suggestions,
        matches: matches,
      );

      // Check if notifier is still valid before updating state
      try {
        state = state.copyWith(data: data, isLoading: false);
      } catch (e) {
        if (e.toString().contains('disposed')) return;
        rethrow;
      }
    } catch (e) {
      try {
        state = state.copyWith(
          isLoading: false,
          error: () => e.toString(),
        );
      } catch (e) {
        if (e.toString().contains('disposed')) return;
        rethrow;
      }
    }
  }

  /// Helper to construct image URL from match data (copied from MatchesViewModel)
  String? _constructMatchImageUrl(Map<String, dynamic> user) {
    String? currentImageId;

    if (user['imageId'] != null && user['imageId'].toString().isNotEmpty) {
      currentImageId = user['imageId'].toString();
    } else if (user['images'] != null &&
        user['images'] is List &&
        (user['images'] as List).isNotEmpty) {
      currentImageId = (user['images'] as List)[0]?.toString();
    } else if (user['imageIds'] != null &&
        user['imageIds'] is List &&
        (user['imageIds'] as List).isNotEmpty) {
      currentImageId = (user['imageIds'] as List)[0]?.toString();
    } else if (user['firstImageId'] != null) {
      currentImageId = user['firstImageId']?.toString();
    }

    if (currentImageId == null || currentImageId.isEmpty) {
      return null;
    }

    return "https://jiffystorebucket.s3.ap-south-1.amazonaws.com/$currentImageId";
  }

  String _mockNameForId(String id) {
    // Simple mock to give names to IDs if missing
    if (id.contains('alex')) return 'Alex';
    if (id.contains('jordan')) return 'Jordan';
    return 'User';
  }

  /// Refresh home data
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// Load more suggestions (pagination)
  Future<void> loadMoreSuggestions() async {
    // TODO: Implement pagination
  }
}
