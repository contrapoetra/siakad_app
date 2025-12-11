// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absensi.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AbsensiAdapter extends TypeAdapter<Absensi> {
  @override
  final int typeId = 10;

  @override
  Absensi read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Absensi(
      id: fields[0] as String,
      kelasId: fields[1] as String,
      mataPelajaranId: fields[2] as String,
      tanggal: fields[3] as DateTime,
      dataKehadiran: (fields[4] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Absensi obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kelasId)
      ..writeByte(2)
      ..write(obj.mataPelajaranId)
      ..writeByte(3)
      ..write(obj.tanggal)
      ..writeByte(4)
      ..write(obj.dataKehadiran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbsensiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
