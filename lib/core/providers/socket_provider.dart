import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/utils.dart';
import 'package:greyfundr/core/providers/campaign_provider.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/features/splitbill/splitbill_provider.dart';
import 'package:greyfundr/shared/environment.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Centralized Socket.IO connection for live updates.
///
/// Resources: `bill`, `event`, `campaign`. Subscribers register a callback
/// that fires whenever a `liveUpdate` event arrives for that resource id —
/// the callback is expected to re-fetch the current details.
class SocketProvider extends ChangeNotifier {
  IO.Socket? _socket;
  bool _connecting = false;

  // resource|id -> callback (typically a "refetch this resource" closure)
  final Map<String, VoidCallback> _subscriptions = {};

  bool get isConnected => _socket?.connected ?? false;

  String get _socketUrl {
    final host = env.host;
    final origin = host.replaceAll(RegExp(r'/api/v\d+/?$'), '');
    return '$origin/live-updates';
  }

  String _key(String resource, String id) => '$resource|$id';

  void connect() {
    if (_socket != null || _connecting) return;
    _connecting = true;

    final socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .build(),
    );

    socket.onConnect((_) {
      log('SocketProvider: connected (${socket.id})');
      // Re-subscribe to every active room on (re)connect.
      for (final key in _subscriptions.keys) {
        final parts = key.split('|');
        if (parts.length == 2) {
          socket.emit('subscribeToResource', {
            'resource': parts[0],
            'id': parts[1],
          });
        }
      }
      notifyListeners();
    });

    socket.onDisconnect((_) {
      log('SocketProvider: disconnected');
      notifyListeners();
    });

    socket.onConnectError((e) => log('SocketProvider: connect error $e'));
    socket.onError((e) => log('SocketProvider: error $e'));

    socket.on('liveUpdate', _handleLiveUpdate);

    _socket = socket;
    _connecting = false;
  }

  void _handleLiveUpdate(dynamic payload) {
    if (payload is! Map) return;
    final map = Map<String, dynamic>.from(payload);

    String? resource;
    String? id;
    if (map['campaignId'] != null) {
      resource = 'campaign';
      id = map['campaignId'].toString();
      handleIncomingCampaignEvent(id);
    } else if (map['eventId'] != null) {
      resource = 'event';
      id = map['eventId'].toString();
      handleIncomingEventEvent(id);
    } else if (map['billId'] != null) {
      resource = 'bill';
      id = map['billId'].toString();
      handleIncomingSplitBillEvent(id);
    }
    if (resource == null || id == null) return;

    final cb = _subscriptions[_key(resource, id)];
    if (cb != null) {
      log('SocketProvider: liveUpdate $resource:$id (${map['type']})');
      cb();
    }
  }

  void handleIncomingSplitBillEvent(String splitBillId) {
    final splitBillProvider = Provider.of<NewSplitBillProvider>(
      Get.context!,
      listen: false,
    );
    splitBillProvider.getSplitBillDetails(splitBillId: splitBillId);
  }

  void handleIncomingCampaignEvent(String campaignId) {
    final campaignProvider = Provider.of<CampaignProvider>(
      Get.context!,
      listen: false,
    );
    campaignProvider.fetchCampaignDetails(campaignId, force: true);
  }

  void handleIncomingEventEvent(String eventId) {
    final eventProvider = Provider.of<EventProvider>(
      Get.context!,
      listen: false,
    );
    eventProvider.getEventById(eventId);
    eventProvider.getEventLeaderboard(eventId);
  }

  /// Subscribe to live updates for a specific resource id. The [onUpdate]
  /// callback is invoked on every relevant `liveUpdate` event — typically
  /// the screen passes its own re-fetch closure.
  void subscribe(String resource, String id, VoidCallback onUpdate) {
    if (id.isEmpty) return;
    final key = _key(resource, id);
    _subscriptions[key] = onUpdate;
    if (_socket?.connected ?? false) {
      _socket!.emit('subscribeToResource', {'resource': resource, 'id': id});
      log('SocketProvider: subscribed to $resource:$id');
    } else {
      // Auto-connect if a screen subscribes before BottomNav initialised it.
      connect();
    }
  }

  void unsubscribe(String resource, String id) {
    if (id.isEmpty) return;
    final key = _key(resource, id);
    if (!_subscriptions.containsKey(key)) return;
    _subscriptions.remove(key);
    if (_socket?.connected ?? false) {
      _socket!.emit('unsubscribeFromResource', {
        'resource': resource,
        'id': id,
      });
    }
  }

  void disconnectSocket() {
    _subscriptions.clear();
    _socket?.dispose();
    _socket = null;
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}
