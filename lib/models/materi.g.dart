// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'materi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MateriAdapter extends TypeAdapter<Materi> {
  @override
  final int typeId = 11;

  @override
  Materi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Materi(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String,
      fileUrl: fields[3] as String?,
      kelasId: fields[4] as String,
      mataPelajaranId: fields[5] as String,
      guruId: fields[6] as String,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Materi obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.fileUrl)
      ..writeByte(4)
      ..write(obj.kelasId)
      ..writeByte(5)
      ..write(obj.mataPelajaranId)
      ..writeByte(6)
      ..write(obj.guruId)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MateriAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
