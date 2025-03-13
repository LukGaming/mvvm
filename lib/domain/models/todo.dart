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
}
