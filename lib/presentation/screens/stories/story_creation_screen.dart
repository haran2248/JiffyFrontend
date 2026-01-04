import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/core/navigation/navigation_service.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'package:jiffy/presentation/screens/stories/models/story_models.dart';
import 'package:jiffy/presentation/screens/stories/story_overlay_colors.dart';

/// Screen for creating a new story with photo and text overlay
class StoryCreationScreen extends ConsumerStatefulWidget {
  const StoryCreationScreen({super.key});

  @override
  ConsumerState<StoryCreationScreen> createState() => _StoryCreationScreenState();
}

class _StoryCreationScreenState extends ConsumerState<StoryCreationScreen> {
  File? _selectedImage;
  final List<TextOverlay> _overlays = [];
  String? _editingOverlayId; // ID of overlay being edited
  String? _draggingOverlayId; // ID of overlay being dragged
  final Map<String, Offset> _dragStartPositions = {}; // Track drag start per overlay
  final Map<String, Offset> _accumulatedDeltas = {}; // Track accumulated delta per overlay
  bool _isDragging = false;
  bool _isOverDeleteButton = false; // Track if finger is over delete button
  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _deleteButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pickImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage() async {
    final photoUploadService = ref.read(photoUploadServiceProvider);
    final imageFile = await photoUploadService.pickImageFromGallery();
    
    if (imageFile != null && mounted) {
      setState(() {
        _selectedImage = imageFile;
      });
    } else if (mounted && _selectedImage == null) {
      // User cancelled, go back
      context.popRoute();
    }
  }

  void _showTextOverlayEditor({String? overlayId}) {
    final existingOverlay = overlayId != null
        ? _overlays.firstWhere((o) => o.id == overlayId, orElse: () => throw StateError('Overlay not found'))
        : null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TextOverlayEditor(
        initialOverlay: existingOverlay,
        onSave: (overlay) {
          setState(() {
            if (overlayId != null) {
              // Update existing overlay
              final index = _overlays.indexWhere((o) => o.id == overlayId);
              if (index != -1) {
                _overlays[index] = overlay;
              }
            } else {
              // Add new overlay
              _overlays.add(overlay);
            }
            _editingOverlayId = null; // Clear editing state to show buttons again
          });
        },
        onDelete: overlayId != null
            ? () {
                setState(() {
                  _overlays.removeWhere((o) => o.id == overlayId);
                  _editingOverlayId = null; // Clear editing state to show buttons again
                });
                Navigator.of(context).pop();
              }
            : null,
      ),
    ).whenComplete(() {
      // Clear editing state when modal is dismissed
      if (mounted) {
        setState(() {
          _editingOverlayId = null;
        });
      }
    });
  }

  Future<void> _saveStory() async {
    if (_selectedImage == null) return;

    // TODO: Upload story to backend with overlays
    // For now, just show a message and go back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Story saved! (Upload functionality coming soon)'),
        ),
      );
      context.popRoute();
    }
  }

  /// Build all overlay widgets with percentage-based positioning
  List<Widget> _buildOverlays(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    
    return _overlays.map((overlay) {
      // Convert percentage (0-100) to pixel position
      // Position is center of text, so we need to account for text size
      final xPercent = overlay.x.clamp(0.0, 100.0);
      final yPercent = overlay.y.clamp(0.0, 100.0);
      
      // Convert percentage to pixels
      final xPx = (screenSize.width * xPercent / 100.0);
      final yPx = (screenSize.height * yPercent / 100.0);
      
      // Get text style for size estimation
      final fontSize = overlay.fontSizePx;
      final isSelected = _editingOverlayId == overlay.id;
      
      return Positioned(
        left: xPx,
        top: yPx,
        child: SizedBox(
          width: screenSize.width * 0.9,
          height: fontSize + 50, // Ensure enough height for hit testing
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // Reset drag state if needed
              if (_isDragging) {
                setState(() {
                  _isDragging = false;
                  _draggingOverlayId = null;
                });
              } else {
                setState(() {
                  _editingOverlayId = overlay.id; // Set editing state to hide buttons
                });
                _showTextOverlayEditor(overlayId: overlay.id);
              }
            },
            onPanStart: (details) {
              setState(() {
                _isDragging = true;
                _draggingOverlayId = overlay.id;
                _editingOverlayId = null; // Clear edit state when dragging starts
                // Store initial position in pixels for drag calculation
                _dragStartPositions[overlay.id] = Offset(xPx, yPx);
                _accumulatedDeltas[overlay.id] = Offset.zero;
              });
            },
            onPanUpdate: (details) {
            if (_dragStartPositions.containsKey(overlay.id)) {
              // Check if finger is over delete button
              final deleteButtonBox = _deleteButtonKey.currentContext?.findRenderObject() as RenderBox?;
              bool overDeleteButton = false;
              
              if (deleteButtonBox != null && _isDragging && _draggingOverlayId == overlay.id) {
                try {
                  final localPosition = deleteButtonBox.globalToLocal(details.globalPosition);
                  final buttonSize = deleteButtonBox.size;
                  
                  overDeleteButton = localPosition.dx >= 0 &&
                      localPosition.dx <= buttonSize.width &&
                      localPosition.dy >= 0 &&
                      localPosition.dy <= buttonSize.height;
                } catch (e) {
                  // Ignore coordinate conversion errors
                }
              }
              
              setState(() {
                _isOverDeleteButton = overDeleteButton;
                
                // Accumulate delta
                _accumulatedDeltas[overlay.id] = 
                    (_accumulatedDeltas[overlay.id] ?? Offset.zero) + details.delta;
                
                // Calculate new position in pixels
                final startPos = _dragStartPositions[overlay.id]!;
                final delta = _accumulatedDeltas[overlay.id]!;
                final newXPx = startPos.dx + delta.dx;
                final newYPx = startPos.dy + delta.dy;
                
                // Convert back to percentage and clamp to 0-100
                final newXPercent = ((newXPx / screenSize.width) * 100.0).clamp(0.0, 100.0);
                final newYPercent = ((newYPx / screenSize.height) * 100.0).clamp(0.0, 100.0);
                
                // Update overlay position
                final index = _overlays.indexWhere((o) => o.id == overlay.id);
                if (index != -1) {
                  _overlays[index] = overlay.copyWith(x: newXPercent, y: newYPercent);
                }
              });
            }
            },
            onPanEnd: (details) {
            // Check if the finger ended up in the delete button area
            final deleteButtonBox = _deleteButtonKey.currentContext?.findRenderObject() as RenderBox?;
            if (deleteButtonBox != null && _isDragging && _draggingOverlayId == overlay.id) {
              // Convert global position to local position relative to delete button
              try {
                final localPosition = deleteButtonBox.globalToLocal(details.globalPosition);
                final buttonSize = deleteButtonBox.size;
                
                // Check if the position is within the delete button bounds
                if (localPosition.dx >= 0 &&
                    localPosition.dx <= buttonSize.width &&
                    localPosition.dy >= 0 &&
                    localPosition.dy <= buttonSize.height) {
                  // Delete the overlay
                  setState(() {
                    _overlays.removeWhere((o) => o.id == overlay.id);
                  });
                }
              } catch (e) {
                // If coordinate conversion fails, ignore
                debugPrint('Error checking delete button hit: $e');
              }
            }
            
            setState(() {
              _isDragging = false;
              _isOverDeleteButton = false;
              _draggingOverlayId = null;
              _dragStartPositions.remove(overlay.id);
              _accumulatedDeltas.remove(overlay.id);
            });
          },
            onPanCancel: () {
              setState(() {
                _isDragging = false;
                _isOverDeleteButton = false;
                _draggingOverlayId = null;
                _dragStartPositions.remove(overlay.id);
                _accumulatedDeltas.remove(overlay.id);
              });
            },
            child: Align(
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(maxWidth: screenSize.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: colorScheme.primary,
                        width: 2,
                        style: BorderStyle.solid,
                      )
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
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
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_selectedImage == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: (_isDragging || _editingOverlayId != null)
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => context.popRoute(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: _selectedImage != null ? _saveStory : null,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: _selectedImage != null
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: Stack(
        key: _stackKey,
        fit: StackFit.expand,
        children: [
          // Image preview
          Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
          ),

        // Render all text overlays
        ..._buildOverlays(context),

          // Delete button (shows when dragging) - positioned at bottom right to avoid Post button
          if (_isDragging && _draggingOverlayId != null)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 120, // Above the control buttons
              right: 16,
              child: Material(
                color: _isOverDeleteButton
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.9)
                    : Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                shape: const CircleBorder(),
                elevation: _isOverDeleteButton ? 8 : 4,
                child: Container(
                  key: _deleteButtonKey,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isOverDeleteButton
                        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.9)
                        : Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                    border: _isOverDeleteButton
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onError,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onError,
                    size: _isOverDeleteButton ? 32 : 28,
                  ),
                ),
              ),
            ),

          // Controls at bottom - only show when not dragging or editing
          if (!_isDragging && _editingOverlayId == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IgnorePointer(
                    ignoring: _isDragging,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Change photo
                        _ControlButton(
                          icon: Icons.photo_library,
                          label: 'Photo',
                          onTap: _pickImage,
                        ),
                        // Add text overlay
                        _ControlButton(
                          icon: Icons.text_fields,
                          label: 'Text',
                          onTap: () => _showTextOverlayEditor(),
                          isActive: _overlays.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Control button for story creation
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget buttonContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Haptic feedback is only available on mobile platforms
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
            HapticFeedback.lightImpact();
          }
          onTap();
        },
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: buttonContent,
      ),
    );
  }
}

/// Text overlay editor bottom sheet with full controls
class _TextOverlayEditor extends StatefulWidget {
  final TextOverlay? initialOverlay;
  final Function(TextOverlay) onSave;
  final VoidCallback? onDelete;

  const _TextOverlayEditor({
    this.initialOverlay,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<_TextOverlayEditor> createState() => _TextOverlayEditorState();
}

class _TextOverlayEditorState extends State<_TextOverlayEditor> {
  late TextEditingController _controller;
  late Color _selectedColor;
  late TextOverlayAlignment _alignment;
  late TextOverlayFontSize _fontSize;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialOverlay?.text ?? '',
    );
    _selectedColor = widget.initialOverlay?.color ?? StoryOverlayColors.white;
    _alignment = widget.initialOverlay?.alignment ?? TextOverlayAlignment.center;
    _fontSize = widget.initialOverlay?.fontSize ?? TextOverlayFontSize.medium;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.initialOverlay != null ? 'Edit Text Overlay' : 'Add Text Overlay',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Text input field
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter text to overlay on image',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            maxLength: 100,
            maxLines: 3,
            autofocus: true,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          const SizedBox(height: 16),
          
          // Font size selector
          Text(
            'Size',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _SizeButton(
                label: 'Small',
                fontSize: TextOverlayFontSize.small,
                isSelected: _fontSize == TextOverlayFontSize.small,
                onTap: () => setState(() => _fontSize = TextOverlayFontSize.small),
              ),
              _SizeButton(
                label: 'Medium',
                fontSize: TextOverlayFontSize.medium,
                isSelected: _fontSize == TextOverlayFontSize.medium,
                onTap: () => setState(() => _fontSize = TextOverlayFontSize.medium),
              ),
              _SizeButton(
                label: 'Large',
                fontSize: TextOverlayFontSize.large,
                isSelected: _fontSize == TextOverlayFontSize.large,
                onTap: () => setState(() => _fontSize = TextOverlayFontSize.large),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Alignment selector
          Text(
            'Alignment',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AlignmentButton(
                icon: Icons.format_align_left,
                alignment: TextOverlayAlignment.left,
                isSelected: _alignment == TextOverlayAlignment.left,
                onTap: () => setState(() => _alignment = TextOverlayAlignment.left),
              ),
              _AlignmentButton(
                icon: Icons.format_align_center,
                alignment: TextOverlayAlignment.center,
                isSelected: _alignment == TextOverlayAlignment.center,
                onTap: () => setState(() => _alignment = TextOverlayAlignment.center),
              ),
              _AlignmentButton(
                icon: Icons.format_align_right,
                alignment: TextOverlayAlignment.right,
                isSelected: _alignment == TextOverlayAlignment.right,
                onTap: () => setState(() => _alignment = TextOverlayAlignment.right),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Color picker
          Text(
            'Color',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: StoryOverlayColors.allColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: colorScheme.primary,
                            width: 3,
                          )
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              if (widget.onDelete != null)
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onDelete,
                      borderRadius: BorderRadius.circular(30),
                      splashColor: colorScheme.error.withValues(alpha: 0.2),
                      highlightColor: colorScheme.error.withValues(alpha: 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: colorScheme.error,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            'Delete',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.onDelete != null) const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_controller.text.trim().isEmpty) {
                        Navigator.of(context).pop();
                        return;
                      }
                      
                      final overlay = TextOverlay(
                        id: widget.initialOverlay?.id ?? 
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        text: _controller.text.trim(),
                        x: widget.initialOverlay?.x ?? 50.0,
                        y: widget.initialOverlay?.y ?? 40.0,
                        color: _selectedColor,
                        alignment: _alignment,
                        fontSize: _fontSize,
                      );
                      widget.onSave(overlay);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(30),
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFEC4899), // Bright pink
                            Color(0xFFD946EF), // Magenta
                            Color(0xFFA855F7), // Deep purple
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA855F7).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.initialOverlay != null ? 'Save' : 'Add',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Size selection button
class _SizeButton extends StatelessWidget {
  final String label;
  final TextOverlayFontSize fontSize;
  final bool isSelected;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.fontSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sizeMap = {
      TextOverlayFontSize.small: 16.0,
      TextOverlayFontSize.medium: 24.0,
      TextOverlayFontSize.large: 32.0,
    };

    return Material(
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.2)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  fontSize: sizeMap[fontSize],
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Alignment selection button
class _AlignmentButton extends StatelessWidget {
  final IconData icon;
  final TextOverlayAlignment alignment;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlignmentButton({
    required this.icon,
    required this.alignment,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary.withValues(alpha: 0.2)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

