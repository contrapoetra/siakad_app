// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengumpulan_tugas.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PengumpulanTugasAdapter extends TypeAdapter<PengumpulanTugas> {
  @override
  final int typeId = 12;

  @override
  PengumpulanTugas read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PengumpulanTugas(
      id: fields[0] as String,
      tugasId: fields[1] as String,
      siswaNis: fields[2] as String,
      content: fields[3] as String?,
      fileUrl: fields[4] as String?,
      nilai: fields[5] as double?,
      feedback: fields[6] as String?,
      submittedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PengumpulanTugas obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tugasId)
      ..writeByte(2)
      ..write(obj.siswaNis)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.fileUrl)
      ..writeByte(5)
      ..write(obj.nilai)
      ..writeByte(6)
      ..write(obj.feedback)
      ..writeByte(7)
      ..write(obj.submittedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PengumpulanTugasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
