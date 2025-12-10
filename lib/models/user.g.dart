// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 5;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      nomorInduk: fields[0] as String,
      password: fields[1] as String,
      role: fields[2] as String,
      requestedRole: fields[3] as String?,
      requestStatus: fields[4] as String?,
      email: fields[5] as String?,
      isPasswordSet: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.nomorInduk)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.requestedRole)
      ..writeByte(4)
      ..write(obj.requestStatus)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.isPasswordSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
