class Todo {
  final String todo, date, time;
  int status;
  dynamic id;
  int notified;
  Todo(
      {this.id,
      required this.todo,
      required this.date,
      required this.time,
      required this.status,
      required this.notified});

  Map<String, Object?> toMap() {
    if (id == null) {
      return {'todo': todo, 'date': date, 'time': time, 'status': status, 'notified': notified};
    } else {
      return {
        'id': id,
        'todo': todo,
        'date': date,
        'time': time,
        'status': status,
        'notified': notified
      };
    }
  }
}
