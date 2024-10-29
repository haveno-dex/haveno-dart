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
import 'package:haveno/src/exceptions/haveno_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/schema/mixins.dart';

/// The [DisputeAgentService] class provides functionalities to manage
/// dispute agents within the Haveno platform. It allows for the registration
/// and unregistration of dispute agents through gRPC calls.
///
/// This service uses a [HavenoChannel] to communicate with the Haveno server.
/// If the client is not connected, operations will throw a [DaemonNotConnectedException].
class DisputeAgentService with GrpcErrorHandler {
  /// The [HavenoChannel] used for making requests to the Haveno server.
  final HavenoChannel havenoChannel = HavenoChannel();

  /// Constructor for [DisputeAgentService] that initializes it with a [HavenoChannel].
  ///
  /// The [havenoChannel] parameter is required to communicate with the Haveno server.
  DisputeAgentService();

  /// Registers a dispute agent on the Haveno server.
  ///
  /// Takes [disputeAgentType] and [registrationKey] as parameters, which define
  /// the type of dispute agent being registered and the key required for registration.
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  ///
  /// Example:
  /// 
  /// ```dart
  /// await disputeAgentService.registerDisputeAgent('mediator', 'some_registration_key');
  /// ```
  Future<void> registerDisputeAgent(String disputeAgentType, String registrationKey) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.disputeAgentsClient!.registerDisputeAgent(RegisterDisputeAgentRequest(
        disputeAgentType: disputeAgentType,
        registrationKey: registrationKey
      ));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  /// Unregisters a dispute agent from the Haveno server.
  ///
  /// Takes [disputeAgentType] as a parameter to specify the type of dispute agent
  /// that needs to be unregistered.
  ///
  /// Throws a [DaemonNotConnectedException] if the [havenoChannel] is not connected.
  ///
  /// Throws specific exceptions depending on the gRPC error encountered.
  ///
  /// Example:
  /// 
  /// ```dart
  /// await disputeAgentService.unregisterDisputeAgent('mediator');
  /// ```
  Future<void> unregisterDisputeAgent(String disputeAgentType) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.disputeAgentsClient!.unregisterDisputeAgent(UnregisterDisputeAgentRequest(
        disputeAgentType: disputeAgentType
      ));
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }
}
