// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengumuman.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PengumumanAdapter extends TypeAdapter<Pengumuman> {
  @override
  final int typeId = 4;

  @override
  Pengumuman read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pengumuman(
      judul: fields[0] as String,
      isi: fields[1] as String,
      tanggal: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Pengumuman obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.judul)
      ..writeByte(1)
      ..write(obj.isi)
      ..writeByte(2)
      ..write(obj.tanggal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PengumumanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
