import 'package:dio/dio.dart';
import 'package:magna_coders/core/network/api_client.dart';
import 'package:magna_coders/core/network/endpoints.dart';
import 'package:magna_coders/features/contracts/domain/contract.dart';

class ContractsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Contract>> getContracts() async {
    try {
      final response = await _dio.get(Endpoints.contracts);
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['contracts'];
        return list.map((json) => Contract.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
