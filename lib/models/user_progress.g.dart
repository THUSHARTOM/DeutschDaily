// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 0;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return UserProgress(
      storyId: fields[0] as String,
      completed: fields[1] as bool,
      quizScore: fields[2] as int,
      keywordsLearned: (fields[3] as List).cast<String>(),
      lastReadAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.storyId)
      ..writeByte(1)
      ..write(obj.completed)
      ..writeByte(2)
      ..write(obj.quizScore)
      ..writeByte(3)
      ..write(obj.keywordsLearned)
      ..writeByte(4)
      ..write(obj.lastReadAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
