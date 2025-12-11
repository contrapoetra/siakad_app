// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MataPelajaranAdapter extends TypeAdapter<MataPelajaran> {
  @override
  final int typeId = 8;

  @override
  MataPelajaran read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MataPelajaran(
      id: fields[0] as String,
      nama: fields[1] as String,
      guruNip: fields[2] as String,
      guruNama: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MataPelajaran obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.guruNip)
      ..writeByte(3)
      ..write(obj.guruNama);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MataPelajaranAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class KelasAdapter extends TypeAdapter<Kelas> {
  @override
  final int typeId = 7;

  @override
  Kelas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Kelas(
      id: fields[0] as String,
      nama: fields[1] as String,
      tingkat: fields[2] as String,
      jurusan: fields[3] as String,
      mataPelajaranList: (fields[4] as List).cast<MataPelajaran>(),
    );
  }

  @override
  void write(BinaryWriter writer, Kelas obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.tingkat)
      ..writeByte(3)
      ..write(obj.jurusan)
      ..writeByte(4)
      ..write(obj.mataPelajaranList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KelasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
