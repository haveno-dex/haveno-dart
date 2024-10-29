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


class NoConnectionException implements Exception {
  final String message;

  NoConnectionException([this.message = 'Permission denied from Daemon']);

  @override
  String toString() => 'NoConnectionException: $message';
}

class NoInternetConnectionException extends NoConnectionException {
  NoInternetConnectionException([super.message = 'You are not connected to the internet']);
}

class DaemonUnavailableException extends NoConnectionException {
  DaemonUnavailableException([super.message = 'The daemon is unavailable']);
}

class DaemonNotConnectedException extends NoConnectionException {
  DaemonNotConnectedException([super.message = "No daemon connection, first connect to the daemon using HavenoChannel.connect()"]);
}

class DaemonTimeoutException extends NoConnectionException {
  DaemonTimeoutException([super.message = 'The daemon connectiion to the daemon timed out']);
}