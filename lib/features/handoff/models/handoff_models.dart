enum HandoffStatus { pendiente, listo, bloqueado }

class Proyecto {
  const Proyecto({
    required this.id,
    required this.name,
    this.repoUrl = '',
    this.license = 'MIT',
    required this.createdAt,
  });

  final String id;
  final String name;
  final String repoUrl;
  final String license;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'repo_url': repoUrl,
        'license': license,
        'created_at': createdAt.toIso8601String(),
      };

  factory Proyecto.fromMap(Map<String, dynamic> map) => Proyecto(
        id: map['id'] as String,
        name: map['name'] as String,
        repoUrl: map['repo_url'] as String? ?? '',
        license: map['license'] as String? ?? 'MIT',
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class HandoffItem {
  const HandoffItem({
    required this.id,
    required this.projectId,
    required this.category,
    required this.title,
    this.notes = '',
    this.evidence = '',
    this.status = HandoffStatus.pendiente,
  });

  final String id;
  final String projectId;
  final String category;
  final String title;
  final String notes;
  final String evidence;
  final HandoffStatus status;

  HandoffItem copyWith({
    String? notes,
    String? evidence,
    HandoffStatus? status,
  }) =>
      HandoffItem(
        id: id,
        projectId: projectId,
        category: category,
        title: title,
        notes: notes ?? this.notes,
        evidence: evidence ?? this.evidence,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'project_id': projectId,
        'category': category,
        'title': title,
        'notes': notes,
        'evidence': evidence,
        'status': status.name,
      };

  factory HandoffItem.fromMap(Map<String, dynamic> map) => HandoffItem(
        id: map['id'] as String,
        projectId: map['project_id'] as String,
        category: map['category'] as String,
        title: map['title'] as String,
        notes: map['notes'] as String? ?? '',
        evidence: map['evidence'] as String? ?? '',
        status: HandoffStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'pendiente'),
          orElse: () => HandoffStatus.pendiente,
        ),
      );
}

