class Todo {
  final String id;
  final String name;
  final String description;
  final bool done;

  const Todo({
    required this.id,
    required this.name,
    required this.description,
    required this.done,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"],
      name: json["name"],
      description: json["description"],
      done: json["done"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'done': done,
    };
  }

  Todo copyWith({
    String? id,
    String? name,
    String? description,
    bool? done,
  }) {
    return Todo(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      done: done ?? this.done,
    );
  }
}
