import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:magna_coders/app/bootstrap.dart';

class WebSocketClient {
  WebSocketChannel? _channel;

  Stream<dynamic>? get messages => _channel?.stream;

  void connect(String token, {String? url}) {
    final base = url ?? ApiConfig.apiBase;
    final uri = Uri.parse(base);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = uri.replace(scheme: scheme);
    final withToken = wsUri.replace(queryParameters: {
      ...wsUri.queryParameters,
      'token': token,
    });
    _channel = WebSocketChannel.connect(withToken);
  }

  void sendMessage(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
