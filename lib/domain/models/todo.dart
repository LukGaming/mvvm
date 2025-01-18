class Todo {
  final int id;
  final String name;

  Todo({
    required this.id,
    required this.name,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json["id"], name: json["name"]);
  }
}
