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

class ResourceException implements Exception {
  final String message;

  ResourceException([this.message = 'Resource exception']);

  @override
  String toString() => 'ResourceException: $message';
}

class NotFoundException extends ResourceException {
  NotFoundException([super.message = 'The resource could not be found']);
}

class AlreadyExistsException extends ResourceException {
  AlreadyExistsException([super.message = 'The resource already exists']);
}

class InvalidArgumentException extends ResourceException {
  InvalidArgumentException([super.message = 'The invalid arguments for this resource']);
}
