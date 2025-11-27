// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siswa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SiswaAdapter extends TypeAdapter<Siswa> {
  @override
  final int typeId = 0;

  @override
  Siswa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Siswa(
      nis: fields[0] as String,
      nama: fields[1] as String,
      kelas: fields[2] as String,
      jurusan: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Siswa obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nis)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.kelas)
      ..writeByte(3)
      ..write(obj.jurusan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiswaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
