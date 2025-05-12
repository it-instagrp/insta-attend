
enum TaskPriority{
  Low, High, Medium
}

enum TaskStatus{
  Todo, InProgress, Finish
}

class Task{
  final String taskTitle;
  final DateTime deadLine;
  final int comment;
  final TaskPriority priority;
  final TaskStatus status;

  const Task({required this.priority, required this.status, required this.taskTitle, required this.comment, required this.deadLine});
}