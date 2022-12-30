class Todo {
  final String todo, date, time;
  int status;
  Todo({required this.todo, required this.date, required this.time, required this.status});

  Map<String,Object?> toMap(){
    return {
      'todo': todo,
      'date': date,
      'time': time,
      'status': status
    };
  }

}
