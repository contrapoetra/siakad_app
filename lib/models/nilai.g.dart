// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nilai.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NilaiAdapter extends TypeAdapter<Nilai> {
  @override
  final int typeId = 3;

  @override
  Nilai read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nilai(
      nis: fields[0] as String,
      namaSiswa: fields[1] as String,
      mataPelajaran: fields[2] as String,
      nilaiTugas: fields[3] as double,
      nilaiUTS: fields[4] as double,
      nilaiUAS: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Nilai obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nis)
      ..writeByte(1)
      ..write(obj.namaSiswa)
      ..writeByte(2)
      ..write(obj.mataPelajaran)
      ..writeByte(3)
      ..write(obj.nilaiTugas)
      ..writeByte(4)
      ..write(obj.nilaiUTS)
      ..writeByte(5)
      ..write(obj.nilaiUAS);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NilaiAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
