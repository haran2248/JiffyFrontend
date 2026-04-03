class ReasonOption {
  final String id;
  final String type;
  final String key;
  final String label;
  final String icon;
  final int ordinal;
  final bool active;

  const ReasonOption({
    required this.id,
    required this.type,
    required this.key,
    required this.label,
    required this.icon,
    required this.ordinal,
    required this.active,
  });

  factory ReasonOption.fromJson(Map<String, dynamic> json) {
    return ReasonOption(
      id: json['id'] as String,
      type: json['type'] as String,
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      ordinal: json['ordinal'] as int,
      active: json['active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'key': key,
      'label': label,
      'icon': icon,
      'ordinal': ordinal,
      'active': active,
    };
  }
}
