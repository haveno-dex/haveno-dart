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

/// A service that handles the retrieval of market price information for XMR
/// (Monero) using the Haveno gRPC API.
///
/// This service class interacts with the Haveno gRPC service through the 
/// [HavenoChannel], sending requests to fetch the latest market prices for 
/// XMR. It also manages exceptions related to gRPC connections and operations.
///
/// The [PriceService] uses the [GrpcErrorHandler] mixin to manage any errors
/// related to gRPC requests and responses.
class PriceService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  ///
  /// This client is required for establishing a connection to the gRPC
  /// server and performing requests such as retrieving market prices.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Creates a new [PriceService] instance.
  ///
  /// The constructor accepts an instance of [HavenoChannel], which is used 
  /// to perform gRPC operations such as fetching market prices. The client 
  /// should already be connected to the Haveno gRPC server before calling
  /// any methods.
  ///
  /// Example:
  /// 
  /// ```dart
  /// final priceClient = PriceService(havenoChannel);
  /// ```
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the Haveno client is not connected.
  PriceService();

  /// Retrieves the current market prices for XMR (Monero) from the Haveno gRPC service.
  ///
  /// This method sends a [MarketPricesRequest] to the Haveno gRPC server and expects a
  /// [MarketPricesReply] containing the list of [MarketPriceInfo] data. Each [MarketPriceInfo]
  /// contains pricing information about XMR in various markets.
  ///
  /// If the Haveno client is not connected to the server, a [DaemonNotConnectedException] 
  /// is thrown, indicating that the gRPC connection is required to fetch the data.
  ///
  /// Example:
  /// 
  /// ```dart
  /// try {
  ///   final prices = await priceClient.getXmrMarketPrices();
  ///   if (prices != null) {
  ///     for (final price in prices) {
  ///       print('Market: ${price.market}, Price: ${price.price}');
  ///     }
  ///   }
  /// } catch (e) {
  ///   print('Error fetching prices: $e');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` that resolves to a `List<MarketPriceInfo>?` containing the current 
  ///   market prices for XMR, or `null` if an error occurs.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the client is not connected to the gRPC server.
  /// - Catches [GrpcError] to handle gRPC-specific errors.
  ///
  /// This method also leverages the [GrpcErrorHandler] mixin to provide custom error
  /// handling for gRPC failures such as network issues or invalid responses.
  Future<List<MarketPriceInfo>?> getXmrMarketPrices() async {
    // Ensure that the Haveno client is connected to the gRPC server.
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }

    // Variable to hold the gRPC response.
    MarketPricesReply getMarketPricesReply;

    try {
      // Make the gRPC call to retrieve market prices.
      getMarketPricesReply = await havenoChannel.priceClient
          !.getMarketPrices(MarketPricesRequest());

      // Return the list of market prices from the gRPC response.
      return getMarketPricesReply.marketPrice;
    } on GrpcError catch (e) {
      // Handle any gRPC errors using the GrpcErrorHandler mixin.
      handleGrpcError(e);
    }

    // Return null if an error occurred during the gRPC request.
    return null;
  }
}