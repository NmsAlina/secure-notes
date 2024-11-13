class Note {
  final int? id;
  final String title;
  final String description;
  int order; // Add order field
  final DateTime creationTime; // Add creation time field

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.creationTime,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        order: json['order'],
        creationTime: DateTime.parse(json['creationTime']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'order': order,
        'creationTime': creationTime.toIso8601String(),
      };
}
