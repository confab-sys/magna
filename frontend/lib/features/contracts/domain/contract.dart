import 'package:json_annotation/json_annotation.dart';

part 'contract.g.dart';

@JsonSerializable()
class Contract {
  final String id;
  final String title;
  final String description;
  
  @JsonKey(name: 'client_id')
  final String clientId;
  
  @JsonKey(name: 'developer_id')
  final String? developerId;
  
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  
  final String status; // DRAFT, ACTIVE, COMPLETED, CANCELLED
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    this.developerId,
    this.totalAmount = 0.0,
    this.status = 'DRAFT',
    required this.createdAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) => _$ContractFromJson(json);
  Map<String, dynamic> toJson() => _$ContractToJson(this);
}
