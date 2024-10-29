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

/// A service that handles the retrieval of trade statistics from the Haveno gRPC API.
/// 
/// The `TradeStatisticsClient` class provides functionality for fetching trade 
/// statistics data from the Haveno server. It communicates via the Haveno gRPC 
/// service and uses the [HavenoChannel] to make requests and receive responses. 
/// 
/// This class also uses the [GrpcErrorHandler] mixin to handle potential gRPC errors.
class TradeStatisticsService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  ///
  /// This client is required to establish a connection to the Haveno gRPC service 
  /// and perform operations such as retrieving trade statistics.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Constructs a [TradeStatisticsService] with the given [HavenoChannel].
  ///
  /// This constructor requires a [HavenoChannel] to interact with the Haveno gRPC
  /// service and retrieve trade statistics. The client must be connected to the
  /// Haveno server before calling any methods.
  ///
  /// Example:
  ///
  /// ```dart
  /// final tradeClient = TradeStatisticsClient(havenoChannel);
  /// ```
  TradeStatisticsService();

  /// Retrieves trade statistics from the Haveno gRPC server.
  ///
  /// This method sends a [GetTradeStatisticsRequest] to the Haveno server and expects
  /// a [GetTradeStatisticsReply] in response, containing a list of [TradeStatistics3].
  /// If the client is not connected to the gRPC server, a [DaemonNotConnectedException]
  /// is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// try {
  ///   final tradeStats = await tradeClient.getTradeStatistics();
  ///   if (tradeStats != null) {
  ///     for (final stat in tradeStats) {
  ///       print('Total Trades: ${stat.totalTrades}');
  ///     }
  ///   }
  /// } catch (e) {
  ///   print('Error fetching trade statistics: $e');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` that resolves to a `List<TradeStatistics3>?` containing the trade statistics, 
  ///   or an empty list `[]` if no statistics are found or an error occurs.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the Haveno client is not connected to the server.
  /// - Catches [GrpcError] to handle any gRPC-specific errors.
  Future<List<TradeStatistics3>?> getTradeStatistics() async {
    // Ensure the Haveno client is connected.
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }

    try {
      // Get the trade statistics client from Haveno.
      GetTradeStatisticsClient? tradeStatisticsClient =
          havenoChannel.tradeStatisticsClient;

      // Request trade statistics from the server.
      GetTradeStatisticsReply? tradeStatisticsReply =
          await tradeStatisticsClient
              ?.getTradeStatistics(GetTradeStatisticsRequest());

      // Return the list of trade statistics from the response.
      return tradeStatisticsReply!.tradeStatistics;
    } on GrpcError catch (e) {
      // Handle gRPC errors using the GrpcErrorHandler mixin.
      handleGrpcError(e);
    }

    // Return an empty list if an error occurs.
    return [];
  }
}