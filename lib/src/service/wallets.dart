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

/// A service that handles wallet-related operations via the Haveno gRPC API.
///
/// The `WalletsService` class provides functions for interacting with the
/// Haveno gRPC server to perform various wallet-related tasks, such as retrieving 
/// balances, addresses, and transactions, creating transactions, and managing
/// wallet passwords.
class WalletsService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Creates a [WalletsService] instance.
  ///
  /// The [havenoChannel] is required to interact with the Haveno gRPC server
  /// to perform wallet-related operations.
  ///
  /// Example:
  ///
  /// ```dart
  /// final walletsClient = WalletsClient(havenoChannel);
  /// ```
  WalletsService();

  /// Retrieves the balances of the wallet.
  ///
  /// This method sends a [GetBalancesRequest] to the Haveno gRPC server and retrieves 
  /// the wallet's balances. If the Haveno client is not connected, a [DaemonNotConnectedException]
  /// is thrown.
  ///
  /// Example:
  ///
  /// ```dart
  /// final balances = await walletService.getBalances();
  /// print('Available balance: ${balances?.available}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing [BalancesInfo] if successful.
  /// - `null` if an error occurs.
  ///
  /// Throws:
  /// - [DaemonNotConnectedException] if the service is not connected to the gRPC server.
  Future<BalancesInfo?> getBalances() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getBalancesReply = await havenoChannel.walletsClient!
          .getBalances(GetBalancesRequest());

      return getBalancesReply.balances;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Retrieves the primary XMR address of the wallet.
  ///
  /// This method sends a [GetXmrPrimaryAddressRequest] to retrieve the primary
  /// XMR address of the wallet.
  ///
  /// Example:
  ///
  /// ```dart
  /// final address = await walletsService.getXmrPrimaryAddress();
  /// print('Primary XMR Address: $address');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the primary address as a `String`.
  /// - `null` if an error occurs.
  Future<String?> getXmrPrimaryAddress() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getXmrPrimaryAddressReply = await havenoChannel.walletsClient!
          .getXmrPrimaryAddress(GetXmrPrimaryAddressRequest());
      return getXmrPrimaryAddressReply.primaryAddress;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Retrieves the XMR transactions associated with the wallet.
  ///
  /// This method sends a [GetXmrTxsRequest] to retrieve all XMR transactions 
  /// associated with the wallet.
  ///
  /// Example:
  ///
  /// ```dart
  /// final transactions = await walletsClient.getXmrTxs();
  /// for (final tx in transactions) {
  ///   print('Transaction: ${tx.txId}');
  /// }
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing a list of [XmrTx] transactions.
  /// - An empty list if an error occurs.
  Future<List<XmrTx>> getXmrTxs() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getXmrTxsReply =
          await havenoChannel.walletsClient!.getXmrTxs(GetXmrTxsRequest());
      return getXmrTxsReply.txs;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return [];
    }
  }

  /// Creates a new XMR transaction for the specified destinations.
  ///
  /// This method sends a [CreateXmrTxRequest] with a list of [XmrDestination] objects 
  /// representing the recipients of the transaction.
  ///
  /// Example:
  ///
  /// ```dart
  /// final tx = await walletsService.createXmrTx([destination1, destination2]);
  /// print('Transaction ID: ${tx?.txId}');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the created [XmrTx].
  /// - `null` if an error occurs.
  Future<XmrTx?> createXmrTx(Iterable<XmrDestination> destinations) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final createXmrTxsReply = await havenoChannel.walletsClient!
          .createXmrTx(CreateXmrTxRequest(destinations: destinations));
      return createXmrTxsReply.tx;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return null;
    }
  }

  /// Relays a signed XMR transaction to the network.
  ///
  /// This method sends a [RelayXmrTxRequest] with the transaction metadata to relay the
  /// transaction to the Monero network.
  ///
  /// Example:
  ///
  /// ```dart
  /// await walletsService.relayXmrTx(txMetadata);
  /// ```
  Future<void> relayXmrTx(String metadata) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.walletsClient!
          .relayXmrTx(RelayXmrTxRequest(metadata: metadata));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Retrieves the XMR seed of the wallet.
  ///
  /// This method sends a [GetXmrSeedRequest] to retrieve the seed of the wallet, 
  /// which can be used for wallet recovery.
  ///
  /// Example:
  ///
  /// ```dart
  /// final seed = await walletsService.getXmrSeed();
  /// print('Wallet Seed: $seed');
  /// ```
  ///
  /// Returns:
  /// - A `Future` containing the seed as a `String`.
  /// - `null` if an error occurs.
  Future<String?> getXmrSeed() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getXmrSeedReply =
          await havenoChannel.walletsClient!.getXmrSeed(GetXmrSeedRequest());
      return getXmrSeedReply.seed;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }

  /// Sets a new password for the wallet.
  ///
  /// This method sends a [SetWalletPasswordRequest] to set a new wallet password.
  ///
  /// Example:
  ///
  /// ```dart
  /// await walletsService.setWalletPassword('newPassword', 'currentPassword');
  /// ```
  Future<void> setWalletPassword(String newPassword, String? password) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.walletsClient!.setWalletPassword(
          SetWalletPasswordRequest(
              password: password, newPassword: newPassword));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Locks the wallet with the provided password.
  ///
  /// This method sends a [LockWalletRequest] to lock the wallet.
  ///
  /// Example:
  ///
  /// ```dart
  /// await walletsService.lockWallet('password');
  /// ```
  Future<void> lockWallet(String password) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.walletsClient!.lockWallet(LockWalletRequest());
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Unlocks the wallet with the provided password.
  ///
  /// This method sends an [UnlockWalletRequest] to unlock the wallet.
  ///
  /// Example:
  ///
  /// ```dart
  /// await walletsService.unlockWallet('password');
  /// ```
  Future<void> unlockWallet(String password) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.walletsClient!.unlockWallet(UnlockWalletRequest());
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Removes the wallet password, leaving the wallet unencrypted.
  ///
  /// This method sends a [RemoveWalletPasswordRequest] to remove the password from
  /// the wallet, effectively making the wallet unencrypted.
  ///
  /// Example:
  ///
  /// ```dart
  /// await walletsService.removeWalletPassword('password');
  /// ```
  Future<void> removeWalletPassword(String password) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.walletsClient!.removeWalletPassword(
          RemoveWalletPasswordRequest(password: password));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }
}