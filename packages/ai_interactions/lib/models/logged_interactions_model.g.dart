// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logged_interactions_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoggedInteractionsModelAdapter
    extends TypeAdapter<LoggedInteractionsModel> {
  @override
  final int typeId = 2;

  @override
  LoggedInteractionsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoggedInteractionsModel(
      timestamp: fields[1] as String,
      interactions: (fields[2] as List).cast<InteractionModel>(),
      isDelete: fields[3] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LoggedInteractionsModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.interactions)
      ..writeByte(3)
      ..write(obj.isDelete);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoggedInteractionsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InteractionModelAdapter extends TypeAdapter<InteractionModel> {
  @override
  final int typeId = 3;

  @override
  InteractionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InteractionModel(
      chatID: fields[1] as String,
      characterID: fields[2] as String,
      usage: fields[3] as InteractionUsageModel,
      prompt: fields[4] as String,
      response: fields[5] as String,
      timestamp: fields[6] as String?,
      language: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, InteractionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(1)
      ..write(obj.chatID)
      ..writeByte(2)
      ..write(obj.characterID)
      ..writeByte(3)
      ..write(obj.usage)
      ..writeByte(4)
      ..write(obj.prompt)
      ..writeByte(5)
      ..write(obj.response)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.language);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InteractionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InteractionUsageModelAdapter extends TypeAdapter<InteractionUsageModel> {
  @override
  final int typeId = 4;

  @override
  InteractionUsageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InteractionUsageModel(
      promptTokens: fields[1] as int,
      completionTokens: fields[2] as int,
      totalTokens: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, InteractionUsageModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(1)
      ..write(obj.promptTokens)
      ..writeByte(2)
      ..write(obj.completionTokens)
      ..writeByte(3)
      ..write(obj.totalTokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InteractionUsageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
