/// Represents a single selectable chip option within a category.
class ChipOption {
  final String id;
  final String label;

  const ChipOption({required this.id, required this.label});

  factory ChipOption.fromJson(Map<String, dynamic> json) {
    return ChipOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

/// Represents a category of chips fetched from /api/chips.
class ChipCategory {
  final String id;
  final String title;
  final String subtitle;
  final List<ChipOption> options;

  const ChipCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.options,
  });

  factory ChipCategory.fromJson(Map<String, dynamic> json) {
    final optionsList = (json['options'] as List<dynamic>)
        .map((o) => ChipOption.fromJson(o as Map<String, dynamic>))
        .toList();
    return ChipCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle']?.toString() ?? '',
      options: optionsList,
    );
  }
}
