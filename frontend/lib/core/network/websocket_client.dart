import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:magna_coders/app/bootstrap.dart';

class WebSocketClient {
  WebSocketChannel? _channel;

  Stream<dynamic>? get messages => _channel?.stream;

  /// Connects to a WebSocket endpoint.
  ///
  /// If [url] is provided as an HTTP/HTTPS URL, it will be converted to
  /// WS/WSS and the `token` will be appended as a query parameter.
  ///
  /// If [url] is omitted, the client will connect to [ApiConfig.apiBase]
  /// upgraded to WS/WSS with the token appended.
  void connect(String token, {String? url}) {
    Uri uri = Uri.parse(url ?? ApiConfig.apiBase);

    // If caller passed an http/https URL, upgrade to ws/wss.
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
      uri = uri.replace(scheme: scheme);
    }

    // Append token if not already present.
    if (!uri.queryParameters.containsKey('token')) {
      uri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
        },
      );
    }

    _channel = WebSocketChannel.connect(uri);
  }

  void sendMessage(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }
}
