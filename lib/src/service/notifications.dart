// Haveno Flutter extends the features of Haveno, supporting mobile devices and more.
// Copyright (C) 2024 Kewbit (https://kewbit.org)
// Source Code: https://git.haveno.com/haveno/flutter_haveno.git
//
// Author: Kewbit
//    Website: https://kewbit.org
//    Contact Email: kewbitxmr@protonmail.com or me@kewbit.org
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:async';
import 'package:grpc/service_api.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/grpc_codegen/grpc.pb.dart';


/// A service class to manage notifications from the Haveno daemon.
class NotificationsService {
  /// Instance of [HavenoChannel] used to communicate with the Haveno service.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// A map holding listeners for each notification type.
  /// Each notification type is associated with a list of callback functions.
  final Map<NotificationMessage_NotificationType, List<void Function(NotificationMessage)>> _listeners = {};

  /// The current subscription to the notification stream.
  StreamSubscription<NotificationMessage>? _notificationSubscription;

  /// A timer used to retry listening after an error or disconnection.
  Timer? _retryTimer;

  /// A flag indicating whether the client is actively listening for notifications.
  bool _isListening = false;

  /// Constructor for [NotificationsService].
  NotificationsService();

  /// Adds a listener for a specific notification type.
  ///
  /// [type] specifies the type of notification to listen for.
  /// [listener] is the callback function to be executed when the notification is received.
  void addListener(NotificationMessage_NotificationType type, void Function(NotificationMessage) listener) {
    _listeners.putIfAbsent(type, () => []).add(listener);
  }

  /// Removes a listener for a specific notification type.
  ///
  /// [type] specifies the type of notification.
  /// [listener] is the callback function to be removed.
  void removeListener(NotificationMessage_NotificationType type, void Function(NotificationMessage) listener) {
    _listeners[type]?.remove(listener);
    if (_listeners[type]?.isEmpty ?? false) {
      _listeners.remove(type);
    }
  }

  /// Starts listening for notifications from the Haveno service.
  ///
  /// If the service is not connected, it will retry every minute until successful.
  /// [retryDelaySeconds] specifies the delay (in seconds) between retries after errors.
  Future<void> listen({int retryDelaySeconds = 5}) async {
    // Prevent multiple listeners from starting.
    if (_isListening) return;

    _isListening = true;

    // Keep retrying until the daemon is connected.
    while (!havenoChannel.isConnected) {
      print('Service is not connected, retrying in 1 minute...');
      await Future.delayed(const Duration(minutes: 1));
    }

    try {
      // Register and listen to notifications from the service.
      ResponseStream<NotificationMessage> responseStream = havenoChannel.notificationsClient!
          .registerNotificationListener(RegisterNotificationListenerRequest());

      _notificationSubscription = responseStream.listen(
        (notification) => _handleNotification(notification),
        onError: (error) {
          print('Error receiving notifications: $error');
          _retryListen(retryDelaySeconds);
        },
        onDone: () {
          print('Notification stream closed');
          _retryListen(retryDelaySeconds);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Failed to start notification listener: $e');
      _retryListen(retryDelaySeconds);
    }
  }

  /// Retries listening for notifications after a delay.
  ///
  /// [retryDelaySeconds] specifies the delay (in seconds) before retrying.
  void _retryListen(int retryDelaySeconds) {
    // Cancel any existing retry timer.
    _retryTimer?.cancel();
    // Set up a new retry timer.
    _retryTimer = Timer(Duration(seconds: retryDelaySeconds), () => listen(retryDelaySeconds: retryDelaySeconds));
  }

  /// Handles a received notification by invoking the corresponding listeners.
  ///
  /// [notification] is the notification message received from the Haveno service.
  void _handleNotification(NotificationMessage notification) {
    print('Received notification: ${notification.toString()}');
    _listeners[notification.type]?.forEach((listener) => listener(notification));
  }

  /// Stops listening for notifications and cleans up resources.
  ///
  /// Cancels the stream subscription and any retry timers.
  void stop() {
    _isListening = false; // Set the flag to indicate listening has stopped.
    _notificationSubscription?.cancel(); // Cancel the stream subscription.
    _retryTimer?.cancel(); // Cancel any retry timers.
    print('Stopped listening to notifications.');
  }
}
