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
import 'package:haveno/src/grpc_codegen/pb.pb.dart';
import 'package:haveno/src/schema/mixins.dart';

/// A provider for XMR (Monero) node settings via the Haveno gRPC API.
///
/// The `XmrNodeProvider` class is responsible for fetching Monero node settings
/// from the Haveno gRPC server. It uses the [HavenoChannel] to send requests and
/// handle responses related to XMR node settings, and it handles gRPC errors
/// using the [GrpcErrorHandler] mixin.
class XmrNodeService with GrpcErrorHandler {

  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Creates an [XmrNodeService] instance.
  ///
  /// The [havenoChannel] is required to interact with the Haveno gRPC server
  /// for fetching Monero node settings for the local node.
  ///
  /// Example:
  ///
  /// ```dart
  /// final xmrNodeProvider = XmrNodeProvider(havenoChannel);
  /// ```
  XmrNodeService();

  /// Fetches the XMR node settings from the server.
  ///
  /// This method sends a [GetXmrNodeSettingsRequest] to retrieve the current local
  /// Monero node settings configured on the Haveno server.
  ///
  /// Example:
  ///
  /// ```dart
  /// final nodeSettings = await xmrNodeProvider.getXmrNodeSettings();
  /// if (nodeSettings != null) {
  ///   print('Blockchain Path: ${nodeSettings.blockchainPath}');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the [XmrNodeSettings].
  /// - `null` if an error occurs or no settings are available.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the client is not connected to the gRPC server.
  Future<XmrNodeSettings?> getXmrNodeSettings() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getXmrNodeSettingsReply = await havenoChannel.xmrNodeClient!
          .getXmrNodeSettings(GetXmrNodeSettingsRequest());
      return getXmrNodeSettingsReply.settings;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }
}