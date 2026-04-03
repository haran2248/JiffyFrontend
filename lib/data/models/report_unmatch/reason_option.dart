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
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'more',
      ordinal: _toInt(json['ordinal']),
      active: _toBool(json['active']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lowercase = value.toLowerCase();
      return lowercase == 'true' || lowercase == '1' || lowercase == 'yes';
    }
    return false;
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
