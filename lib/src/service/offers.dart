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
import 'package:grpc/grpc.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/exceptions/connection_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/schema/mixins.dart';
import 'package:fixnum/fixnum.dart' as fixnum;

/// Client class to handle offer-related operations with the Haveno Daemon.
/// 
/// This class provides methods to interact with the Haveno network to manage 
/// trade offers, including fetching peer offers, fetching user's offers, posting
/// new offers, canceling existing offers, and editing offers.
class OfferService with GrpcErrorHandler {
  /// Client used to communicate with the Haveno Daemon.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Constructs an [OfferService] instance with the given [HavenoChannel].
  OfferService();

  /// Fetches all offers from the Haveno network.
  /// 
  /// This method first calls [getPeerOffers] to fetch offers from other peers,
  /// then waits for 2 seconds before calling [getMyOffers] to fetch the user's own offers.
  /// 
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  Future<void> getAllOffers() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    await getPeerOffers();
    await Future.delayed(const Duration(seconds: 2));
    await getMyOffers();
  }

  /// Fetches the list of offers from peers on the Haveno network.
  /// 
  /// Returns a [List] of [OfferInfo] objects representing peer offers.
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  /// Catches [GrpcError] exceptions and handles them using [handleGrpcError].
  Future<List<OfferInfo>> getPeerOffers() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }

    List<OfferInfo> peerOffers = [];

    try {
      final getOffersReply = await havenoChannel.offersClient!.getOffers(GetOffersRequest());
      peerOffers = getOffersReply.offers;
      return peerOffers;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return peerOffers;
    }
  }

  /// Fetches the user's own offers from the Haveno network.
  /// 
  /// Returns a [List] of [OfferInfo] objects representing the user's offers.
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  /// Catches [GrpcError] exceptions and handles them using [handleGrpcError].
  Future<List<OfferInfo>> getMyOffers() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }

    // Fetch from the server
    final getMyOffersReply = await havenoChannel.offersClient!.getMyOffers(GetMyOffersRequest());
    var myOffers = getMyOffersReply.offers;

    // Save to local database
    List<OfferInfo> myTradeOffers = [];
    try {
      for (var myOffer in myOffers) {
        myOffer.isMyOffer = true;
        myTradeOffers.add(myOffer);
      }
      return myTradeOffers;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return myTradeOffers;
    }
  }

  /// Posts a new offer to the Haveno network.
  /// 
  /// Returns an [OfferInfo] object representing the newly posted offer.
  /// 
  /// Parameters:
  /// - [currencyCode]: The currency code for the offer (e.g., USD, BTC).
  /// - [direction]: The direction of the offer, either "buy" or "sell".
  /// - [price]: The price of the offer as a string.
  /// - [useMarketBasedPrice]: Whether to use a market-based price.
  /// - [marketPriceMarginPct]: Optional percentage margin for market-based pricing.
  /// - [amount]: The amount for the offer.
  /// - [minAmount]: The minimum amount for the offer.
  /// - [buyerSecurityDepositPct]: The percentage of buyer's security deposit.
  /// - [triggerPrice]: Optional trigger price for the offer.
  /// - [reserveExactAmount]: Whether to reserve the exact amount.
  /// - [paymentAccountId]: The ID of the payment account.
  /// 
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  /// Catches [GrpcError] exceptions and handles them using [handleGrpcError].
  Future<OfferInfo> postOffer({
    required String currencyCode,
    required String direction,
    required String price,
    required bool useMarketBasedPrice,
    double? marketPriceMarginPct,
    required fixnum.Int64 amount,
    required fixnum.Int64 minAmount,
    required double buyerSecurityDepositPct,
    String? triggerPrice,
    required bool reserveExactAmount,
    required String paymentAccountId,
  }) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final postOfferResponse = await havenoChannel.offersClient!.postOffer(
        PostOfferRequest(
          currencyCode: currencyCode,
          direction: direction,
          price: price,
          useMarketBasedPrice: useMarketBasedPrice,
          marketPriceMarginPct: marketPriceMarginPct,
          amount: amount,
          minAmount: minAmount,
          buyerSecurityDepositPct: buyerSecurityDepositPct,
          triggerPrice: triggerPrice,
          reserveExactAmount: reserveExactAmount,
          paymentAccountId: paymentAccountId,
        ),
      );
      return postOfferResponse.offer;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      rethrow;
    }
  }

  /// Cancels an existing offer on the Haveno network.
  /// 
  /// Parameters:
  /// - [offerId]: The ID of the offer to cancel.
  /// 
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  /// Catches [GrpcError] exceptions and handles them using [handleGrpcError].
  Future<void> cancelOffer(String offerId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      havenoChannel.offersClient!.cancelOffer(CancelOfferRequest(id: offerId));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Edits an existing offer on the Haveno network.
  /// 
  /// Parameters:
  /// - [offerId]: The ID of the offer to edit.
  /// - [marketPriceMarginPct]: Optional new percentage margin for market-based pricing.
  /// - [triggerPrice]: Optional new trigger price for the offer.
  /// 
  /// Throws a [DaemonNotConnectedException] if the client is not connected to the daemon.
  /// Catches [GrpcError] exceptions and handles them using [handleGrpcError].
  /// 
  /// Note: This method is currently not implemented in the Haveno daemon.
  Future<void> editOffer({required String offerId, double? marketPriceMarginPct, String? triggerPrice}) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // not implemented at daemon
    } on GrpcError catch (e) {
      handleGrpcError(e);
      rethrow;
    }
  }
}
