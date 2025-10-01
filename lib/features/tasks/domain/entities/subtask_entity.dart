import 'package:equatable/equatable.dart';

class SubtaskEntity extends Equatable {
  final String content;
  final bool completed;

  const SubtaskEntity({required this.content, required this.completed});

  static String encodeSubtasks(List<SubtaskEntity> subtasks) {
    return subtasks
        .map<String>((s) => '${s.content}^${s.completed ? 1 : 0}')
        .join('~');
  }

  static List<SubtaskEntity> decodeSubtasks(String encoding) {
    if (encoding.isEmpty) return [];

    return encoding.split('~').map((s) {
      final split = s.split('^');
      return SubtaskEntity(content: split[0], completed: split[1] == '1');
    }).toList();
  }

  SubtaskEntity copyWith({String? content, bool? completed}) {
    return SubtaskEntity(
      content: content ?? this.content,
      completed: completed ?? this.completed,
    );
  }

  @override
  List<Object?> get props => [content, completed];
}
