// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guru.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GuruAdapter extends TypeAdapter<Guru> {
  @override
  final int typeId = 1;

  @override
  Guru read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Guru(
      nip: fields[0] as String,
      nama: fields[1] as String,
      email: fields[2] as String,
      tanggalLahir: fields[3] as DateTime,
      tempatLahir: fields[4] as String,
      gelar: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Guru obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.nip)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.tanggalLahir)
      ..writeByte(4)
      ..write(obj.tempatLahir)
      ..writeByte(5)
      ..write(obj.gelar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuruAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
