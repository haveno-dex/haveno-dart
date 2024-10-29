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
import 'package:haveno/src/grpc_codegen/grpc.pbgrpc.dart';

/// A singleton class to manage gRPC connections and client instances
/// for interacting with the Haveno daemon.
class HavenoChannel {
  // Static instance for singleton
  static final HavenoChannel _instance = HavenoChannel._internal();

  // Private constructor for singleton
  HavenoChannel._internal();

  /// Factory constructor to provide a singleton instance of HavenoChannel.
  factory HavenoChannel() {
    return _instance;
  }

  // Private variables for internal state
  String? _host;
  int? _port;
  String? _password;
  dynamic _channel;

  // Client instances for gRPC services
  AccountClient? accountClient;
  DisputesClient? disputesClient;
  GetVersionClient? versionClient;
  HelpClient? helpClient;
  DisputeAgentsClient? disputeAgentsClient;
  NotificationsClient? notificationsClient;
  XmrConnectionsClient? xmrConnectionsClient;
  XmrNodeClient? xmrNodeClient;
  OffersClient? offersClient;
  PaymentAccountsClient? paymentAccountsClient;
  PriceClient? priceClient;
  GetTradeStatisticsClient? tradeStatisticsClient;
  ShutdownServerClient? shutdownServerClient;
  TradesClient? tradesClient;
  WalletsClient? walletsClient;

  // Completer to track the connection state
  final Completer<void> _connectionCompleter = Completer<void>();

  /// Getter to check if the channel is currently connected.
  bool get isConnected => _channel != null;

  /// Asynchronous method to connect to the Haveno daemon.
  ///
  /// Takes [host], [port], and [password] as parameters to initialize
  /// the connection. If already connected, it will return early.
  Future<void> connect(String host, int port, String password) async {
    if (isConnected) {
      print(
          "We tried to connect to the Haveno daemon a second time, if you need to reconnect you must disconnect first then run .connect()");
      return; // Already connected, do nothing.
    }

    _host = host;
    _port = port;
    _password = password;

    // Initializing the gRPC channel
    _channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: const ChannelCredentials.insecure(),
        codecRegistry: CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
        connectionTimeout: const Duration(seconds: 30),
        idleTimeout: const Duration(minutes: 10),
      ),
    );

    // Initialize clients for each gRPC service
    _initializeClients();
    await _checkConnection();
    _connectionCompleter.complete();
  }

  /// A future that completes when the connection is established.
  Future<void> get onConnected => _connectionCompleter.future;

  /// Internal method to initialize gRPC service clients.
  ///
  /// Throws an exception if HavenoChannel is not properly initialized.
  void _initializeClients() {
    if (_host == null || _port == null || _password == null || _channel == null) {
      throw Exception('HavenoChannel not properly initialized');
    }
    print("Started initializing clients...");

    // Set the CallOptions with metadata (e.g., password)
    final callOptions = CallOptions(metadata: {'password': _password!});

    // Initialize each client using the channel and call options
    accountClient = AccountClient(_channel!, options: callOptions);
    disputesClient = DisputesClient(_channel!, options: callOptions);
    versionClient = GetVersionClient(_channel!, options: callOptions);
    helpClient = HelpClient(_channel!, options: callOptions);
    disputeAgentsClient = DisputeAgentsClient(_channel!, options: callOptions);
    notificationsClient = NotificationsClient(_channel!, options: callOptions);
    xmrConnectionsClient = XmrConnectionsClient(_channel!, options: callOptions);
    xmrNodeClient = XmrNodeClient(_channel!, options: callOptions);
    offersClient = OffersClient(_channel!, options: callOptions);
    paymentAccountsClient = PaymentAccountsClient(_channel!, options: callOptions);
    priceClient = PriceClient(_channel!, options: callOptions);
    tradeStatisticsClient = GetTradeStatisticsClient(_channel!, options: callOptions);
    shutdownServerClient = ShutdownServerClient(_channel!, options: callOptions);
    tradesClient = TradesClient(_channel!, options: callOptions);
    walletsClient = WalletsClient(_channel!, options: callOptions);

    print("Initialized all clients!");
  }

  /// Internal method to check the connection with the Haveno daemon.
  ///
  /// Optionally retries connection until successful if [untilSuccessful] is true.
  /// Takes [cooldownInterval] to specify the delay between retries.
  Future<bool> _checkConnection({bool untilSuccessful = true, Duration cooldownInterval = const Duration(seconds: 10)}) async {
    bool success = false;

    // Retry connection loop if necessary
    do {
      try {
        var getVersionReply = await versionClient?.getVersion(GetVersionRequest());

        // Check if a valid version is returned by the daemon
        if (getVersionReply != null && getVersionReply.hasVersion()) {
          print("Successfully got the version for the daemon as ${getVersionReply.version}");
          success = true;
        } else {
          print("The daemon returned a null server version, so the connection was a failure");
          success = false;
        }
      } catch (e) {
        // Handle connection failure
        print("Failed to make an initial connection: $e");
        print("We used the following details... HOST: $_host PORT: $_port PASSWORD: $_password");
        success = false;
      }

      // Retry logic
      if (!success && untilSuccessful) {
        print("Retrying connection in ${cooldownInterval.inSeconds} seconds...");
        await Future.delayed(cooldownInterval); // Wait before retrying
      }

    } while (!success && untilSuccessful); // Retry if necessary

    return success;
  }

  /// Disconnects from the Haveno daemon and shuts down the gRPC channel.
  Future<void> shutdown() async {
    if (!isConnected) {
      return; // Not connected, do nothing.
    }
    await _channel!.shutdown();
    _resetClients();
  }

  /// Gracefully disconnects from the Haveno daemon by shutting down the channel.
  Future<void> disconnect() async {
    if (!isConnected) {
      return; // Not connected, do nothing.
    }
    await _channel!.shutdown();
    _resetClients();
  }

  /// Resets all gRPC service clients to null and clears the channel.
  void _resetClients() {
    _channel = null;
    accountClient = null;
    disputesClient = null;
    versionClient = null;
    helpClient = null;
    disputeAgentsClient = null;
    notificationsClient = null;
    xmrConnectionsClient = null;
    xmrNodeClient = null;
    offersClient = null;
    paymentAccountsClient = null;
    priceClient = null;
    tradeStatisticsClient = null;
    shutdownServerClient = null;
    tradesClient = null;
    walletsClient = null;
  }
}

/* class TorClientTransportConnector implements ClientTransportConnector {
  final String targetHost;
  final int targetPort;
  final String proxyHost;
  final int? proxyPort;
  final bool _useRust = false;
  late Socket _socket;
//  late SOCKSSocket? _rustSocksSocket;

  TorClientTransportConnector(
    this.targetHost,
    this.targetPort, {
    this.proxyHost = '127.0.0.1',
    this.proxyPort = 9050,
  });

  @override
  Future<ClientTransportConnection> connect() async {
    print("Connecting to proxy 127.0.0.1:$proxyPort for $targetHost:$targetPort");
    _socket = await _connectToProxy(targetHost, targetPort);
    return ClientTransportConnection.viaSocket(_socket);
  }

  // This version works with Orbot
  Future<Socket> _connectToProxy(String host, int port) async {
    // Log start of the connection process
    print('Attempting to connect to proxy at $host:$port');
    
    // Establish SOCKS5 connection through the proxy.
    var proxySocket = await SocksTCPClient.connect(
      [ProxySettings(InternetAddress.tryParse('127.0.0.1')!, proxyPort!)], 
      InternetAddress(host, type: InternetAddressType.unix), 
      port,
    );
    
    // Check if the socket is connected
    if (proxySocket.socket != null && proxySocket.socket.remoteAddress != null) {
      print('Successfully connected to proxy. Remote address: ${proxySocket.socket.remoteAddress}');
    } else {
      print('Failed to connect to the proxy. Socket or remote address is null.');
    }

    // Log the connection details
    print('Socket connected to ${proxySocket.socket.remoteAddress}:${proxySocket.socket.remotePort}');
    
    // Log a success message
    print('Proxy connection established.');

    return proxySocket.socket;
  }
  
  @override
  Future<void> get done => Future.value(); //socket.done;

  @override
  void shutdown() {
   // if (_rustSocksSocket != null && _useRust) {
   //   _rustSocksSocket!.close();
   // } else {
   //   _socket.close();
   // }
  }

  @override
  String get authority => '$targetHost:$targetPort'; */

/*   Future<Socket> _connectToProxyRust(String host, int port) async {
    print('Starting SOCKS5 connection through native Tor...');
    print('Proxy Host: $proxyHost, Proxy Port: $proxyPort');
    print('Target Host: $host, Target Port: $port');

    try {
      final proxySocket = await SOCKSSocket.create(
        proxyHost: InternetAddress.loopbackIPv4.address,
        proxyPort: proxyPort!,
        sslEnabled: false,
      );
      print('SOCKSSocket created: $proxySocket');

      print('Attempting to connect to the proxy...');
      await proxySocket.connect();
      print('Successfully connected to the SOCKS5 proxy on $proxyHost:$proxyPort');

      await Future.delayed(const Duration(seconds: 2));
      print('Connection delay complete, proceeding to connect to the target host...');

      await proxySocket.connectTo(host, port);

      await Future.delayed(const Duration(seconds: 2));
      print('Successfully connected to target host $host:$port through the SOCKS5 proxy.');

      //await proxySocket.listen(onData)

      _rustSocksSocket = proxySocket;
      return proxySocket.socket;

    } catch (e, stackTrace) {
      print('Error during SOCKS5 connection: $e');
      print('StackTrace: $stackTrace');
      rethrow;
    }
  }

} */