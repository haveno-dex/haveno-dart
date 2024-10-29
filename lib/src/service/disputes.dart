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
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:grpc/grpc.dart';
import 'package:haveno/src/channel/haveno_channel.dart';
import 'package:haveno/src/exceptions/haveno_exceptions.dart';
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';
import 'package:haveno/src/grpc_codegen/pb.pb.dart';
import 'package:haveno/src/schema/mixins.dart';

class DisputeService with GrpcErrorHandler {
  final HavenoChannel havenoChannel = HavenoChannel();
  List<Dispute> _disputes = [];

  // Map to hold StreamControllers for each chat
  final Map<String, StreamController<List<ChatMessage>>> _chatControllers = {};

  // Map to store unique chat messages for each dispute
  final Map<String, List<ChatMessage>> _chatMessages = {};

  // Map to store tradeId to disputeId mapping
  final Map<String, String> _disputeToTradeIdMap = {};

  // TradeID to dispute map
  final Map<String, Dispute> _tradeIdToDisputeMap = {};

  DisputeService(); //: super(const Duration(minutes: 1));


  // Method to get or create a StreamController for a specific chat
  Stream<List<ChatMessage>> chatMessagesStream(String disputeId) {
    if (!_chatControllers.containsKey(disputeId)) {
      _chatControllers[disputeId] = StreamController<List<ChatMessage>>.broadcast();
    }
    return _chatControllers[disputeId]!.stream;
  }

  // Load initial messages independently of stream creation
  Future<List<ChatMessage?>?> loadInitialMessages(String disputeId) async {
    Dispute? _dispute;
    // Retrieve the tradeId from the mapping
    final tradeId = _disputeToTradeIdMap[disputeId];
    if (tradeId == null) return null;

    // Retrieve the dispute from the _disputes list using the disputeId
    try {
      _dispute = _disputes.firstWhere((d) => d.id == disputeId);
    } catch (e) {
      return null;
    }

      debugPrint("Setting chat messages for dispute: $disputeId with ${_dispute.chatMessage.length} messages");

      // Store the chat messages in _chatMessages for this disputeId
      _chatMessages[disputeId] = _dispute.chatMessage;

      // If a stream controller exists for this disputeId, add the messages to the stream
      if (_chatControllers.containsKey(disputeId)) {
        _chatControllers[disputeId]!.add(_chatMessages[disputeId]!);
      }
    return null;
  }

  List<ChatMessage> getInitialChatMessages(String disputeId) {
    debugPrint("Getting initial chat messages for dispute: $disputeId");
    return _chatMessages[disputeId] ?? [];
  }


  Dispute? getDisputeByTradeId(String tradeId) {
    debugPrint("Attempting to retrieve dispute for Trade ID: $tradeId");

    if (_tradeIdToDisputeMap.containsKey(tradeId)) {
      debugPrint("Dispute found for Trade ID: $tradeId");
      return _tradeIdToDisputeMap[tradeId];
    } else {
      debugPrint("No dispute found for Trade ID: $tradeId");
      //debugPrintTradeIdToDisputeMap(); // Print the entire map for debugging
      return null;
    }
  }

  Future<List<Dispute>> getDisputes() async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      // Attempt to retrieve disputes from the service
      GetDisputesReply? getDisputesReply = await havenoChannel.disputesClient?.getDisputes(GetDisputesRequest());

      // Ensure the reply is not null
      if (getDisputesReply == null) {
        debugPrint("getDisputesReply is null, cannot proceed.");
        return [];
      }

      // Extract the list of disputes
      List<Dispute> disputesList = getDisputesReply.disputes;

      // Check if the disputes list is empty
      if (disputesList.isEmpty) {
        debugPrint("No disputes found.");
      } else {
        // Iterate through each dispute and map the tradeId to the dispute
        for (var dispute in disputesList) {
          _disputeToTradeIdMap[dispute.id] = dispute.tradeId;
          _tradeIdToDisputeMap[dispute.tradeId] = dispute;

          // Debugging output to verify the mapping
          debugPrint("Mapping added: Trade ID ${dispute.tradeId} -> Dispute ID ${dispute.id}");
          debugPrint("Current _tradeIdToDisputeMap contents:");
          _tradeIdToDisputeMap.forEach((tradeId, mappedDispute) {
            debugPrint("Trade ID: $tradeId, Dispute ID: ${mappedDispute.id}");
          });
        }
      }
      _disputes = disputesList;
      return _disputes;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return [];
    }
  }

Future<Dispute?> getDispute(String tradeId) async {
  if (!havenoChannel.isConnected) {
    throw DaemonNotConnectedException();
  }
  try {

    GetDisputeReply? getDisputeReply = await havenoChannel.disputesClient?.getDispute(GetDisputeRequest(tradeId: tradeId));

    Dispute newDispute = getDisputeReply!.dispute;
    
    _disputeToTradeIdMap[newDispute.id] = tradeId;
    _tradeIdToDisputeMap[newDispute.tradeId] = newDispute;

    // Update the _disputes list or map if necessary
    final int existingIndex = _disputes.indexWhere((d) => d.id == newDispute.id);

    if (existingIndex != -1) {
      _disputes[existingIndex] = newDispute;
    } else {
      _disputes.add(newDispute);
    }
    return newDispute;
  } on GrpcError catch (e) {
    handleGrpcError(e);
    return null;
  }
}

  Future<void> resolveDispute(String tradeId, DisputeResult_Winner? winner, DisputeResult_Reason? reason, String? summaryNotes, Int64? customPayoutAmount) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }

    Dispute? dispute = await getDispute(tradeId);
    if (!dispute!.isOpener) {
      throw Exception("You can't close a dispute you didn't open!");
    }

    try {
      await havenoChannel.disputesClient?.resolveDispute(ResolveDisputeRequest(
        tradeId: tradeId,
        winner: winner,
        reason: reason,
        summaryNotes: summaryNotes,
        customPayoutAmount: customPayoutAmount,
      ));

      getDisputes();
    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  Future<Dispute?> openDispute(String tradeId) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.disputesClient?.openDispute(OpenDisputeRequest(tradeId: tradeId));
      await getDisputes();
      Dispute? dispute = _disputes.firstWhere((d) => d.tradeId == tradeId);
      return dispute;
    } on GrpcError catch (e) {
      handleGrpcError(e);
      return null;
    }
  }

  Future<void> sendDisputeChatMessage(String disputeId, String message, Iterable<Attachment> attachments) async {
    if (!havenoChannel.isConnected) {
      throw DaemonNotConnectedException();
    }
    try {
      await havenoChannel.disputesClient?.sendDisputeChatMessage(SendDisputeChatMessageRequest(
        disputeId: disputeId,
        message: message,
        attachments: attachments,
      ));

      // Might need to create a fake protobuf message and add it to the stream controller just to conform (so the message appears instantly)

    } on GrpcError catch (e) {
      handleGrpcError(e);
    }
  }

  // Optional: Method to close a specific chat stream
  void closeChat(String disputeId) {
    if (_chatControllers.containsKey(disputeId)) {
      _chatControllers[disputeId]!.close();
      _chatControllers.remove(disputeId);
      _chatMessages.remove(disputeId);
      _disputeToTradeIdMap.remove(disputeId);
    }
  }

}
