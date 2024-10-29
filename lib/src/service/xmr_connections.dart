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

import 'package:grpc/grpc.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/exceptions/connection_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/schema/mixins.dart';

/// A service that manages XMR (Monero) node connections via the Haveno gRPC API.
///
/// The `XmrConnectionsClient` class provides functionality for fetching, checking,
/// adding, removing, and managing Monero node connections. It communicates with
/// the Haveno gRPC service and uses the [HavenoChannel] to perform the necessary
/// gRPC requests. It also handles gRPC errors using the [GrpcErrorHandler] mixin.
class XmrConnectionsService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Creates a [XmrConnectionsService] instance.
  ///
  /// The [havenoChannel] is required to interact with the Haveno gRPC server to
  /// manage Monero node connections.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xmrConnectionsClient = XmrConnectionsClient(havenoChannel);
  /// ```
  XmrConnectionsService();

  /// Fetches the list of XMR connections from the server.
  ///
  /// This method sends a [GetConnectionsRequest] to retrieve all XMR connections
  /// from the Haveno gRPC server.
  ///
  /// Example:
  ///
  /// ```dart
  /// final connections = await xmrConnectionsClient.getXmrConnectionSettings();
  /// for (final connection in connections) {
  ///   print('Node URL: ${connection.url}');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing a list of [UrlConnection] representing the node connections.
  /// - An empty list if an error occurs.
  Future<List<UrlConnection>> getXmrConnectionSettings() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final response = await havenoChannel.xmrConnectionsClient!
          .getConnections(GetConnectionsRequest());
      return response.connections;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return [];
  }

  /// Checks the status of XMR connections from the server.
  ///
  /// This method sends a [CheckConnectionsRequest] to check the status of all
  /// XMR connections from the Haveno gRPC server.
  ///
  /// Example:
  ///
  /// ```dart
  /// final connections = await xmrConnectionsClient.checkConnections();
  /// for (final connection in connections) {
  ///   print('Connection Status: ${connection.onlineStatus}');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing a list of [UrlConnection].
  /// - An empty list if an error occurs.
  Future<List<UrlConnection>> checkConnections() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final response = await havenoChannel.xmrConnectionsClient!
          .checkConnections(CheckConnectionsRequest());
      return response.connections;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return [];
  }

  /// Sets the active XMR node connection on the server.
  ///
  /// This method sends a [SetConnectionRequest] to the Haveno gRPC server to set
  /// a new active XMR node. The connection is also set locally.
  ///
  /// Example:
  ///
  /// ```dart
  /// final newConnection = await xmrConnectionsClient.setConnection(connection);
  /// print('New Active Node: ${newConnection?.url}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the new active [UrlConnection].
  /// - `null` if an error occurs.
  Future<UrlConnection?> setConnection(UrlConnection connection) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.xmrConnectionsClient!
          .setConnection(SetConnectionRequest(connection: connection));
      return connection; // Set the new active node locally
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Fetches the currently active XMR connection from the server.
  ///
  /// This method sends a [GetConnectionRequest] to retrieve the currently active
  /// XMR node connection.
  ///
  /// Example:
  ///
  /// ```dart
  /// final activeConnection = await xmrConnectionsClient.getActiveConnection();
  /// print('Active Node: ${activeConnection?.url}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the active [UrlConnection].
  /// - `null` if an error occurs.
  Future<UrlConnection?> getActiveConnection() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final response = await havenoChannel.xmrConnectionsClient!
          .getConnection(GetConnectionRequest());
      return response.connection;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return null;
    }
  }

  /// Checks whether the selected XMR connection is online.
  ///
  /// This method sends a [CheckConnectionRequest] to verify if the selected
  /// XMR connection is online.
  ///
  /// Example:
  ///
  /// ```dart
  /// final isOnline = await xmrConnectionsClient.checkConnection();
  /// print('Connection is online: $isOnline');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing `true` if the connection is online, `false` otherwise.
  Future<bool?> checkConnection() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final response = await havenoChannel.xmrConnectionsClient!
          .checkConnection(CheckConnectionRequest());
      return response.connection.onlineStatus == UrlConnection_OnlineStatus.ONLINE;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Adds a new XMR connection to the list of available connections.
  ///
  /// This method sends an [AddConnectionRequest] to add a new XMR node connection
  /// to the server.
  ///
  /// Example:
  ///
  /// ```dart
  /// await xmrConnectionsClient.addConnection(newConnection);
  /// print('Connection added.');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing `true` if the connection is successfully added.
  /// - `null` if an error occurs.
  Future<bool?> addConnection(UrlConnection connection) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.xmrConnectionsClient!
          .addConnection(AddConnectionRequest(connection: connection));
      return true;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Removes a specific XMR connection from the list of available connections.
  ///
  /// This method sends a [RemoveConnectionRequest] to remove a node connection
  /// based on the provided URL.
  ///
  /// Example:
  ///
  /// ```dart
  /// await xmrConnectionsClient.removeConnection('node-url');
  /// print('Connection removed.');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing `true` if the connection is successfully removed.
  /// - `null` if an error occurs.
  Future<bool?> removeConnection(String url) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.xmrConnectionsClient!
          .removeConnection(RemoveConnectionRequest(url: url));
      return true;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Enables or disables automatic switching to the best XMR connection.
  ///
  /// This method sends a [SetAutoSwitchRequest] to configure whether the best
  /// XMR connection should be automatically selected.
  ///
  /// Example:
  ///
  /// ```dart
  /// await xmrConnectionsClient.setAutoSwitchBestConnection(true);
  /// print('Auto-switch enabled.');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing `true` if the setting is successfully updated.
  /// - `null` if an error occurs.
  Future<bool?> setAutoSwitchBestConnection(bool autoSwitch) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.xmrConnectionsClient!
          .setAutoSwitch(SetAutoSwitchRequest(autoSwitch: autoSwitch));
      return true;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Gets the auto-switch connection setting for the Haveno daemon.
  /// 
  /// This method queries the Haveno daemon to check whether the automatic
  /// switching to the best available Monero (XMR) connection is enabled or
  /// disabled.
  ///
  /// If the Haveno channel is not connected, a [DaemonNotConnectedException] will
  /// be thrown.
  ///
  /// It returns a [bool] indicating the current auto-switch setting:
  /// - `true` if auto-switch is enabled.
  /// - `false` if auto-switch is disabled.
  /// 
  /// If there is a communication error (e.g., a gRPC error), the error will be
  /// caught and handled using the [handleGrpcError] method.
  ///
  /// ### Parameters:
  /// - `autoSwitch`: A boolean flag that specifies the setting to check for the
  /// auto-switch mechanism (not actively used in this method but could be passed).
  ///
  /// ### Returns:
  /// - A [Future] that resolves to a [bool] indicating the auto-switch state:
  ///   - `true`: Auto-switch is enabled.
  ///   - `false`: Auto-switch is disabled.
  ///   - `null`: If an error occurs or if no response is received.
  ///
  /// ### Throws:
  /// - [DaemonNotConnectedException] if the Haveno daemon is not connected.
  /// 
  /// ### Example usage:
  /// ```dart
  /// bool? autoSwitchStatus = await getAutoSwitchBestConnection();
  /// if (autoSwitchStatus != null && autoSwitchStatus) {
  ///   print("Auto-switch to best XMR connection is enabled.");
  /// } else {
  ///   print("Auto-switch to best XMR connection is disabled.");
  /// }
  /// ```
  Future<bool?> getAutoSwitchBestConnection(bool autoSwitch) async {
    // Check if the Haveno daemon is connected.
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException(); // Throw exception if not connected.
    }
    
    try {
      // Send request to get the current auto-switch setting from the XMR connections client.
      GetAutoSwitchReply getAutoSwitchReply = await havenoChannel.xmrConnectionsClient!
          .getAutoSwitch(GetAutoSwitchRequest());
      
      // Return the current auto-switch setting.
      return getAutoSwitchReply.autoSwitch;
    } on GrpcError catch (e) {
      // Handle any gRPC-related errors.
      handleGrpcError(e);
    }
    
    // Return null if an error occurs or no valid response is received.
    return null;
  }
}