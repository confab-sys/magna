// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      clientId: json['client_id'] as String,
      developerId: json['developer_id'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'client_id': instance.clientId,
      'developer_id': instance.developerId,
      'total_amount': instance.totalAmount,
      'status': instance.status,
      'created_at': instance.createdAt.toIso8601String(),
    };
