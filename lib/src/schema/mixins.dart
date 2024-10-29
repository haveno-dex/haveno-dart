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
import '../exceptions/haveno_exceptions.dart';

mixin GrpcErrorHandler {
  /// @nodoc  
  void handleGrpcError(GrpcError e) {
    //debugPrint("Daemon gRPC error: $e");
    switch (e.code) {
      case StatusCode.unavailable:
        throw DaemonUnavailableException('The daemon is unavailable. Please check your network connection.');
      case StatusCode.unauthenticated:
        throw DaemonAuthenticationException('Invalid credentials provided.');
      case StatusCode.invalidArgument:
        throw InvalidArgumentException('The provided arguments are invalid.');
      case StatusCode.deadlineExceeded:
        throw DaemonTimeoutException('The request timed out. Please try again.');
      case StatusCode.permissionDenied:
        throw PermissionDeniedException('You do not have permission to perform this action.');
      case StatusCode.notFound:
        throw NotFoundException('The requested resource was not found.');
      case StatusCode.alreadyExists:
        throw AlreadyExistsException('The resource you are trying to create already exists.');
      default:
        // Re-throw the original error if it does not match any known cases
        throw Exception(e);
    }
  }
}