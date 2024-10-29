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
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:grpc/grpc.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/exceptions/connection_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/grpc_codegen/pb.pb.dart';
import 'package:haveno/src/schema/mixins.dart';

/// A service that handles trade-related operations via the Haveno gRPC API.
///
/// This service allows you to perform various trade-related actions, such as
/// fetching trade data, sending chat messages, confirming payments, and more.
/// It uses the [HavenoChannel] for gRPC communication and provides error handling
/// via the [GrpcErrorHandler] mixin.
class TradesService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Constructs a [TradesService] instance.
  ///
  /// The [havenoChannel] is required to interact with the Haveno gRPC server
  /// for various trade-related operations.
  ///
  /// Example:
  /// 
  /// ```dart
  /// final tradesClient = TradesClient(havenoChannel);
  /// ```
  TradesService();

  /// Retrieves all trades from the Haveno gRPC server.
  ///
  /// This method sends a [GetTradesRequest] to fetch all available trades.
  /// If the Haveno client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final trades = await tradesService.getTrades();
  /// if (trades != null) {
  ///   for (final trade in trades) {
  ///     print('Trade ID: ${trade.tradeId}');
  ///   }
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing a `List<TradeInfo>` of available trades.
  /// - An empty list if an error occurs.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the client is not connected to the gRPC server.
  Future<List<TradeInfo>?> getTrades() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getTradesReply =
          await havenoChannel.tradesClient!.getTrades(GetTradesRequest());
      return getTradesReply.trades;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return [];
  }

  /// Retrieves a specific trade by its trade ID.
  ///
  /// Sends a [GetTradeRequest] with the provided [tradeId] and fetches
  /// details about the trade. If the client is not connected, a 
  /// [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final trade = await tradesService.getTrade('1234');
  /// print('Trade ID: ${trade?.tradeId}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the `TradeInfo` for the specified trade.
  /// - `null` if an error occurs.
  Future<TradeInfo?> getTrade(String tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getTradeReply = await havenoChannel.tradesClient!
          .getTrade(GetTradeRequest(tradeId: tradeId));
      return getTradeReply.trade;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return null;
    }
  }

  /// Takes an offer by providing the offer ID, payment account ID, and amount.
  ///
  /// Sends a [TakeOfferRequest] to take an offer, and if successful, returns
  /// the details of the trade. If the client is not connected, a 
  /// [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final trade = await tradesService.takeOffer('offerId', 'paymentId', amount);
  /// print('Trade ID: ${trade?.tradeId}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the `TradeInfo` if the offer is successfully taken.
  /// - `null` if an error occurs.
  Future<TradeInfo?> takeOffer(
      String? offerId, String? paymentAccountId, fixnum.Int64 amount) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final takeOfferReply = await havenoChannel.tradesClient!.takeOffer(
          TakeOfferRequest(
              offerId: offerId,
              paymentAccountId: paymentAccountId,
              amount: amount));
      return takeOfferReply.trade;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return null;
    }
  }

  /// Sends a chat message for a specific trade.
  ///
  /// Sends a [SendChatMessageRequest] to send a message in the trade's chat.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// await tradesService.sendChatMessage('tradeId', 'Hello!');
  /// ```
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the client is not connected to the gRPC server.
  Future<void> sendChatMessage(String? tradeId, String? message) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.tradesClient!.sendChatMessage(
          SendChatMessageRequest(tradeId: tradeId, message: message));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Retrieves chat messages for a specific trade by its trade ID.
  ///
  /// Sends a [GetChatMessagesRequest] to fetch messages from the trade's chat.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final messages = await tradesService.getChatMessages('tradeId');
  /// for (final message in messages) {
  ///   print('Message: ${message.text}');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing a `List<ChatMessage>` of chat messages for the trade.
  Future<List<ChatMessage>> getChatMessages(String tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getChatMessagesReply = await havenoChannel.tradesClient!
          .getChatMessages(GetChatMessagesRequest(tradeId: tradeId));
      return getChatMessagesReply.message;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return [];
    }
  }

  /// Confirms that the payment has been sent for a specific trade.
  ///
  /// Sends a [ConfirmPaymentSentRequest] to mark the payment as sent.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// await tradesService.confirmPaymentSent('tradeId');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the updated `TradeInfo` after confirming payment.
  Future<TradeInfo?> confirmPaymentSent(String tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.tradesClient!
          .confirmPaymentSent(ConfirmPaymentSentRequest(tradeId: tradeId));
      await getTrade(tradeId);
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Confirms that the payment has been received for a specific trade.
  ///
  /// Sends a [ConfirmPaymentReceivedRequest] to mark the payment as received.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// await tradesService.confirmPaymentReceived('tradeId');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the updated `TradeInfo` after confirming payment.
  Future<TradeInfo?> confirmPaymentReceived(String tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.tradesClient!.confirmPaymentReceived(
          ConfirmPaymentReceivedRequest(tradeId: tradeId));
      return await getTrade(tradeId);
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Completes a trade by marking it as finished.
  ///
  /// Sends a [CompleteTradeRequest] to mark a trade as completed.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// await tradesService.completeTrade('tradeId');
  /// ```
  Future<void> completeTrade(String? tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.tradesClient!
          .completeTrade(CompleteTradeRequest(tradeId: tradeId));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Withdraws funds for a specific trade to the specified address.
  ///
  /// Sends a [WithdrawFundsRequest] to withdraw funds from the trade.
  /// If the client is not connected, a [DaemonNotConnectedException] is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// await tradesService.withdrawFunds('tradeId', 'address', 'memo');
  /// ```
  Future<void> withdrawFunds(
      String? tradeId, String? address, String? memo) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.tradesClient!.withdrawFunds(
          WithdrawFundsRequest(tradeId: tradeId, address: address, memo: memo));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

}