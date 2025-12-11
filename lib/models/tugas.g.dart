// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tugas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TugasAdapter extends TypeAdapter<Tugas> {
  @override
  final int typeId = 9;

  @override
  Tugas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tugas(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String,
      kelasId: fields[3] as String,
      mataPelajaranId: fields[4] as String,
      guruId: fields[5] as String,
      deadline: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Tugas obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.kelasId)
      ..writeByte(4)
      ..write(obj.mataPelajaranId)
      ..writeByte(5)
      ..write(obj.guruId)
      ..writeByte(6)
      ..write(obj.deadline)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TugasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
