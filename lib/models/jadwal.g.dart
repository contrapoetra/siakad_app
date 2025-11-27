// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jadwal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JadwalAdapter extends TypeAdapter<Jadwal> {
  @override
  final int typeId = 2;

  @override
  Jadwal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Jadwal(
      hari: fields[0] as String,
      jam: fields[1] as String,
      mataPelajaran: fields[2] as String,
      guruPengampu: fields[3] as String,
      kelas: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Jadwal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.hari)
      ..writeByte(1)
      ..write(obj.jam)
      ..writeByte(2)
      ..write(obj.mataPelajaran)
      ..writeByte(3)
      ..write(obj.guruPengampu)
      ..writeByte(4)
      ..write(obj.kelas);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JadwalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
