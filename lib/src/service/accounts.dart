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

import 'package:fixnum/fixnum.dart';
import 'package:grpc/grpc.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/exceptions/connection_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/schema/mixins.dart';

/// The [AccountService] class provides various functionalities for managing
/// a user's account on the Haveno platform. It includes methods to check if an
/// account exists, create an account, change the password, and handle potential
/// gRPC errors.
///
/// This service is designed to work with a [HavenoChannel], which must be 
/// connected to perform operations. The service throws custom exceptions 
/// if the client is not connected or if any gRPC errors are encountered.
class AccountService with GrpcErrorHandler {
  /// The [HavenoChannel] used for making requests to the Haveno server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// A flag indicating whether the account exists on the Haveno server.
  /// The value is null if the existence check has not been performed yet.
  //bool? _accountExists;

  /// Constructor for [AccountService] that initializes it with a [HavenoChannel].
  ///
  /// The [havenoChannel] parameter is required and must be connected to
  /// perform any operations.
  AccountService();

  /// Getter to retrieve the account existence flag.
  ///
  /// Returns `true` if the account exists, `false` if it does not exist,
  /// or `null` if the existence check has not been performed.
  //bool? get accountExists => _accountExists;

  /// Checks if an account exists on the Haveno server.
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  /// 
  /// Returns `true` if the account exists, `false` otherwise.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<bool> accountExists() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final accountExistsReply = await havenoChannel.accountClient!.accountExists(AccountExistsRequest());
      return accountExistsReply.accountExists;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return false;
    }
  }

  /// Creates a new account on the Haveno daemon using the specified [password].
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<void> createAccount(String password) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.accountClient!.createAccount(CreateAccountRequest(password: password));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Changes the account password on the Haveno daemon.
  ///
  /// Takes the [oldPassword] and the [newPassword] as parameters.
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.accountClient!.changePassword(ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword));
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
    }
  }

  // needs research
  Future<void> backupAccount() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Need to check what this is actually returning #TODO
      havenoChannel.accountClient!.backupAccount(BackupAccountRequest());
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
    }
  }

  /// Check an the account is initialized on the daemon
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  /// 
  /// Returns `true` if the daemon is initialized with an account, `false` otherwise.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<bool> isAppInitialized() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Need to check what this is actually returning #TODO
      var isAppInitializedReply = await havenoChannel.accountClient!.isAppInitialized(IsAppInitializedRequest());
      return isAppInitializedReply.isAppInitialized;
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
      return false;
    }
  }

  Future<void> restoreAccount(List<int> zipBytes, Int64 offset, Int64 totalLength, bool hasMore) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Need to check what this is actually returning #TODO
      await havenoChannel.accountClient!.restoreAccount(RestoreAccountRequest(zipBytes: zipBytes, offset: offset, totalLength: totalLength, hasMore: hasMore));
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
    }
  }

  /// Closes the currently active account from the daemon
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<void> closeAccount() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Need to check what this is actually returning #TODO
      await havenoChannel.accountClient!.closeAccount(CloseAccountRequest());
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
    }
  }

  /// Deletes the currently active account from the daemon
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<void> deleteAccount() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Need to check what this is actually returning #TODO
      await havenoChannel.accountClient!.deleteAccount(DeleteAccountRequest());
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
    }
  }

  /// Check if an account is open on the daemon
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  /// 
  /// Returns `true` if the daemon is initialized with an account, `false` otherwise.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  Future<bool> isAccountOpen() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      var isAccountOpenReply = await havenoChannel.accountClient!.isAccountOpen(IsAccountOpenRequest());
      return isAccountOpenReply.isAccountOpen;
    } on GrpcError catch (e) {
      // Will need to catch whatever exception is thrown for invalid password
      handleGrpcError(e);
      return false;
    }
  }

  /// Opens an account with the Haveno backend, ensuring the gRPC channel is connected
  /// before making the request.
  ///
  /// Throws:
  ///   - [DaemonNotConnectedException] if the Haveno daemon is not connected.
  ///   - [GrpcError] if any gRPC error occurs during the request, with custom handling for invalid password errors.
  ///
  /// Parameters:
  ///   - `password`: The password for the account. If `null`, the default behavior will be applied.
  Future<void> openAccount(String? password) async {
    // Check if the Haveno channel is connected
    if (!havenoChannel.isConnected) {
      // Throw custom exception if not connected
      throw DaemonNotConnectedException();
    }
    
    try {
      // Make gRPC call to open the account
      await havenoChannel.accountClient!.openAccount(OpenAccountRequest(
        password: password,  // Send password (could be null)
      ));
    } on GrpcError catch (e) {
      // Handle gRPC error (e.g., invalid password error)
      handleGrpcError(e);
    }
  }
}