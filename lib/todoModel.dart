class Todo {
  final String todo, date, time;
  Todo({required this.todo, required this.date, required this.time});

  Map<String,Object?> toMap(){
    return {
      'todo': todo,
      'date': date,
      'time': time
    };
  }

}
