import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';
import 'package:jiffy/presentation/widgets/avatar.dart';

/// Story viewer screen that displays stories with swipe navigation,
/// pause/resume on tap, and automatic progression.
class StoryViewerScreen extends ConsumerStatefulWidget {
  final List<Story> stories;
  final int initialStoryIndex;
  final int initialContentIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialStoryIndex = 0,
    this.initialContentIndex = 0,
  });

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  late PageController _storyPageController;
  late int _currentStoryIndex;
  late int _currentContentIndex;
  Timer? _timer;
  bool _isPaused = false;
  static const Duration _storyDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.initialStoryIndex;
    _currentContentIndex = widget.initialContentIndex;
    _storyPageController = PageController(initialPage: _currentStoryIndex);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _storyPageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isPaused) return;

    _timer?.cancel();
    _timer = Timer(_storyDuration, () {
      if (!mounted || _isPaused) return;
      _nextContent();
    });
  }

  void _nextContent() {
    final currentStory = widget.stories[_currentStoryIndex];
    
    if (_currentContentIndex < currentStory.contents.length - 1) {
      // Move to next content in same story
      setState(() {
        _currentContentIndex++;
      });
      _startTimer();
    } else {
      // Move to next story
      _nextStory();
    }
  }

  void _previousContent() {
    if (_currentContentIndex > 0) {
      setState(() {
        _currentContentIndex--;
      });
      _startTimer();
    } else {
      // Move to previous story
      _previousStory();
    }
  }

  void _nextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      _storyPageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last story, close viewer
      context.popRoute();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      _storyPageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // First story, close viewer
      context.popRoute();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    if (_isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _onStoryPageChanged(int index) {
    // Cancel current timer before changing story
    _timer?.cancel();
    setState(() {
      _currentStoryIndex = index;
      _currentContentIndex = 0;
    });
    // Restart timer for new story
    _startTimer();
  }

  /// Build tap zone indicators (left/right chevrons) when paused
  List<Widget> _buildTapZoneIndicators() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return [
      // Left indicator
      Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        width: screenWidth / 3,
        child: IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ),
      // Right indicator
      Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        width: screenWidth / 3,
        child: IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  void _onTap(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;
    
    if (tapX < screenWidth / 3) {
      // Left side - previous
      _previousContent();
    } else if (tapX > screenWidth * 2 / 3) {
      // Right side - next
      _nextContent();
    } else {
      // Center - pause/resume
      _togglePause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTap,
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _storyPageController,
              onPageChanged: _onStoryPageChanged,
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return _StoryContentPage(
                  key: ValueKey('story_${story.id}_content_${index == _currentStoryIndex ? _currentContentIndex : 0}'),
                  story: story,
                  contentIndex: index == _currentStoryIndex ? _currentContentIndex : 0,
                );
              },
            ),

            // Progress indicators
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: _StoryProgressIndicator(
                story: widget.stories[_currentStoryIndex],
                currentIndex: _currentContentIndex,
                isPaused: _isPaused,
              ),
            ),

            // Gradient overlay at top for header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Top bar with user info and controls
            Positioned(
              top: MediaQuery.of(context).padding.top + 40,
              left: 0,
              right: 0,
              child: _StoryTopBar(
                story: widget.stories[_currentStoryIndex],
                isPaused: _isPaused,
                onClose: () => context.popRoute(),
                onTogglePause: _togglePause,
              ),
            ),

            // Pause indicator
            if (_isPaused)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

            // Tap zone indicators when paused
            if (_isPaused)
              ..._buildTapZoneIndicators(),

            // Story counter at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: _StoryCounter(
                current: _currentContentIndex + 1,
                total: widget.stories[_currentStoryIndex].contents.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual story content page
class _StoryContentPage extends StatefulWidget {
  final Story story;
  final int contentIndex;

  const _StoryContentPage({
    super.key,
    required this.story,
    required this.contentIndex,
  });

  @override
  State<_StoryContentPage> createState() => _StoryContentPageState();
}

class _StoryContentPageState extends State<_StoryContentPage> {
  final GlobalKey _stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.story.contents.isEmpty || widget.contentIndex >= widget.story.contents.length) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Text(
            'No content',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      );
    }

    final content = widget.story.contents[widget.contentIndex];

    return Stack(
      key: _stackKey,
      fit: StackFit.expand,
      children: [
        // Image
        content.isLocal
            ? Image.file(
                File(content.imageUrl),
                fit: BoxFit.cover,
              )
            : Image.network(
                content.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[900],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[900],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),

        // Render all text overlays (non-interactive, viewing mode)
        ..._buildOverlays(context, content),
      ],
    );
  }

  /// Build all overlay widgets with percentage-based positioning (read-only)
  List<Widget> _buildOverlays(BuildContext context, StoryContent content) {
    final screenSize = MediaQuery.of(context).size;
    
    return content.overlays.map((overlay) {
      // Convert percentage (0-100) to pixel position
      final xPercent = overlay.x.clamp(0.0, 100.0);
      final yPercent = overlay.y.clamp(0.0, 100.0);
      
      // Convert percentage to pixels
      final xPx = (screenSize.width * xPercent / 100.0);
      final yPx = (screenSize.height * yPercent / 100.0);
      
      final fontSize = overlay.fontSizePx;
      
      return Positioned(
        left: xPx,
        top: yPx,
        child: IgnorePointer(
          // Make overlays non-interactive in viewer
          child: Transform.translate(
            offset: Offset(-50, -fontSize / 2), // Center the text
            child: Container(
              constraints: BoxConstraints(maxWidth: screenSize.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                overlay.text,
                style: TextStyle(
                  color: overlay.color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                textAlign: overlay.textAlign,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Progress indicator for story contents
class _StoryProgressIndicator extends StatelessWidget {
  final Story story;
  final int currentIndex;
  final bool isPaused;

  const _StoryProgressIndicator({
    required this.story,
    required this.currentIndex,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    if (story.contents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(story.contents.length, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _StoryProgressBar(
                isActive: index == currentIndex,
                isCompleted: index < currentIndex,
                isPaused: isPaused && index == currentIndex,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Individual progress bar
class _StoryProgressBar extends StatefulWidget {
  final bool isActive;
  final bool isCompleted;
  final bool isPaused;

  const _StoryProgressBar({
    required this.isActive,
    required this.isCompleted,
    required this.isPaused,
  });

  @override
  State<_StoryProgressBar> createState() => _StoryProgressBarState();
}

class _StoryProgressBarState extends State<_StoryProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    if (widget.isCompleted) {
      _controller.value = 1.0;
    } else if (widget.isActive && !widget.isPaused) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_StoryProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isCompleted) {
      _controller.value = 1.0;
    } else if (widget.isActive) {
      if (widget.isPaused) {
        _controller.stop();
      } else {
        _controller.forward();
      }
    } else {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _controller.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Top bar with user info and close button
class _StoryTopBar extends StatelessWidget {
  final Story story;
  final bool isPaused;
  final VoidCallback onClose;
  final VoidCallback onTogglePause;

  const _StoryTopBar({
    required this.story,
    required this.isPaused,
    required this.onClose,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // User avatar and name with pink border (per spec)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Avatar(
              radius: 20,
              imageUrl: story.userImageUrl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  story.userName ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  _formatTime(story.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
              ],
            ),
          ),

          // Pause/Play button
          IconButton(
            icon: Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
            ),
            onPressed: onTogglePause,
          ),

          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}

/// Story counter widget showing current/total
class _StoryCounter extends StatelessWidget {
  final int current;
  final int total;

  const _StoryCounter({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          // Backdrop blur effect
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Text(
          '$current / $total',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }
}

