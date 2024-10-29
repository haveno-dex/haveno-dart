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

class HelpService with GrpcErrorHandler {
  
  /// The Haveno client used to communicate with the Haveno gRPC server.
  final HavenoChannel havenoChannel = HavenoChannel();

  Future<String?> getMethodHelp(String methodName) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      final getHelpReply = await havenoChannel.helpClient!
          .getMethodHelp(GetMethodHelpRequest(methodName: methodName));

      return getHelpReply.methodHelp;
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
    return null;
  }
}