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
import 'package:haveno/src/exceptions/haveno_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/grpc_codegen/pb.pb.dart';
import 'package:haveno/src/schema/mixins.dart';

/// A service that provides methods to interact with payment accounts and payment methods
/// using the Haveno gRPC client.
///
/// This class contains methods to fetch payment methods, create payment accounts, and 
/// retrieve payment account forms from the Haveno daemon.
class PaymentAccountService with GrpcErrorHandler {
  /// The gRPC client for interacting with the Haveno daemon.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Constructs a [PaymentAccountService] with the provided [HavenoChannel].
  PaymentAccountService();
  
  /// Fetches the list of all available payment methods from the Haveno daemon.
  ///
  /// Returns a [List] of [PaymentMethod] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns an empty list if the operation fails.
  Future<List<PaymentMethod>?> getPaymentMethods() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    List<PaymentMethod> paymentMethods = [];
    try {
      final getPaymentMethodsReply = await havenoChannel.paymentAccountsClient!
          .getPaymentMethods(GetPaymentMethodsRequest());
      paymentMethods = getPaymentMethodsReply.paymentMethods;
      return paymentMethods;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return paymentMethods;
    }
  }

  /// Fetches all the payment accounts associated with the current user.
  ///
  /// Returns a [List] of [PaymentAccount] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns an empty list if the operation fails.
  Future<List<PaymentAccount>> getPaymentAccounts() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    List<PaymentAccount> paymentAccounts = [];
    try {
      final getPaymentAccountsReply = await havenoChannel
          .paymentAccountsClient!
          .getPaymentAccounts(GetPaymentAccountsRequest());
      paymentAccounts = getPaymentAccountsReply.paymentAccounts;
      return paymentAccounts;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return paymentAccounts;
    }
  }

  /// Fetches all the cryptocurrency payment methods supported by the Haveno daemon.
  ///
  /// Returns a [List] of [PaymentMethod] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns an empty list if the operation fails.
  Future<List<PaymentMethod>> getCryptoCurrencyPaymentMethods() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    List<PaymentMethod> cryptoCurrencyPaymentMethods = [];
    try {
      final getCryptoCurrencyPaymentMethodsReply = await havenoChannel
          .paymentAccountsClient!
          .getCryptoCurrencyPaymentMethods(
              GetCryptoCurrencyPaymentMethodsRequest());
      cryptoCurrencyPaymentMethods = getCryptoCurrencyPaymentMethodsReply.paymentMethods;
      return cryptoCurrencyPaymentMethods;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return cryptoCurrencyPaymentMethods;
    }
  }

  /// Retrieves the payment account form for a specific payment method.
  ///
  /// [paymentMethodId] - The ID of the payment method.
  ///
  /// Returns a [PaymentAccountForm] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns `null` if the form could not be retrieved or does not exist.
  Future<PaymentAccountForm?> getPaymentAccountForm(String paymentMethodId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    PaymentAccountForm? paymentAccountForm;
    try {
      // Fetch from the remote service if not found locally
      final paymentAccountFormReply = await havenoChannel.paymentAccountsClient!.getPaymentAccountForm(
        GetPaymentAccountFormRequest(paymentMethodId: paymentMethodId),
      );

      if (paymentAccountFormReply.hasPaymentAccountForm()) {
        paymentAccountForm = paymentAccountFormReply.paymentAccountForm;
        return paymentAccountForm;
      } else {
        return null;
      }
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return paymentAccountForm;
    }
  }

  /// Retrieves all available payment account forms for the current user.
  ///
  /// Returns a [List] of [PaymentAccountForm] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns an empty list if the operation fails.
  Future<List<PaymentAccountForm>?> getAllPaymentAccountForms() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    List<PaymentAccountForm> paymentAccountForms = [];
    List<PaymentMethod> paymentMethods = (await getPaymentMethods())!;

    try {
      for (var paymentMethod in paymentMethods) {
        var paymentAccountForm = await getPaymentAccountForm(paymentMethod.id);
        if (paymentAccountForm == null) continue;

        if (!paymentAccountForms.contains(paymentAccountForm)) {
          paymentAccountForms.add(paymentAccountForm);
        }
      }
      return paymentAccountForms;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return paymentAccountForms;
    }
  }

  /// Creates a new payment account using the provided [PaymentAccountForm].
  ///
  /// [form] - The payment account form containing details for the new account.
  ///
  /// Returns the created [PaymentAccount] if the operation is successful.
  ///
  /// Throws a [DaemonNotConnectedException] if the client is not connected.
  /// Returns `null` if the account creation fails.
  Future<PaymentAccount?> createPaymentAccount(PaymentAccountForm form) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    PaymentAccount? paymentAccount;
    try {
      final createdPaymentAccount = await havenoChannel.paymentAccountsClient!
          .createPaymentAccount(
              CreatePaymentAccountRequest(paymentAccountForm: form));
      paymentAccount = createdPaymentAccount.paymentAccount;
      return paymentAccount;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return paymentAccount;
    }
  }
}
