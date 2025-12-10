// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siswa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SiswaAdapter extends TypeAdapter<Siswa> {
  @override
  final int typeId = 6;

  @override
  Siswa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Siswa(
      nis: fields[0] as String,
      nama: fields[1] as String,
      email: fields[2] as String,
      tanggalLahir: fields[3] as DateTime,
      tempatLahir: fields[4] as String,
      namaAyah: fields[5] as String,
      namaIbu: fields[6] as String,
      kelas: fields[7] as String,
      jurusan: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Siswa obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.nis)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.tanggalLahir)
      ..writeByte(4)
      ..write(obj.tempatLahir)
      ..writeByte(5)
      ..write(obj.namaAyah)
      ..writeByte(6)
      ..write(obj.namaIbu)
      ..writeByte(7)
      ..write(obj.kelas)
      ..writeByte(8)
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
