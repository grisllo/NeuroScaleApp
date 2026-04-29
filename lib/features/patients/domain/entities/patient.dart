class Patient {
  const Patient({
    required this.id,
    required this.userId,
    required this.alias,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String alias;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient copyWith({
    String? id,
    String? userId,
    String? alias,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      Patient(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        alias: alias ?? this.alias,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      other is Patient &&
      other.id == id &&
      other.userId == userId &&
      other.alias == alias &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(id, userId, alias, notes);
}
