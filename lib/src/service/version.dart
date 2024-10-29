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

/// A service that handles the retrieval of the Haveno daemon version via gRPC.
///
/// The `GetVersionService` communicates with the Haveno gRPC server to fetch
/// the current version of the daemon. It uses the [HavenoChannel] to perform 
/// the gRPC request and returns the version of the daemon.
class GetVersionService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Creates a [GetVersionService] instance.
  ///
  /// The [havenoChannel] is required to interact with the Haveno gRPC server 
  /// and fetch the version information.
  ///
  /// Example:
  /// 
  /// ```dart
  /// final versionService = GetVersionService(havenoChannel);
  /// ```
  GetVersionService();


  /// Fetches the current version of the Haveno daemon from the gRPC server.
  ///
  /// This method sends a [GetVersionRequest] to the Haveno gRPC server and retrieves
  /// the current version of the daemon, storing it in [_version]. If the Haveno client 
  /// is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  /// 
  /// ```dart
  /// final fetchedVersion = await versionClient.fetchVersion();
  /// print(fetchedVersion); // Outputs the current daemon version
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the fetched version as a `String`.
  /// - `null` if an error occurs during the fetch operation.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the Haveno client is not connected to the gRPC server.
  Future<String?> fetchVersion() async {
    // Check if the Haveno client is connected to the gRPC server.
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Send the GetVersionRequest to the Haveno gRPC server.
      final versionReply =
          await havenoChannel.versionClient!.getVersion(GetVersionRequest());
      // Return the version.
      return versionReply.version;
    } on GrpcError catch (e) {
      // Handle gRPC errors using the GrpcErrorHandler mixin.
      handleGrpcError(e);
    }
    // Return null if an error occurs.
    return null;
  }
}