# Haveno Client

<div align="center">
  <img src="https://raw.githubusercontent.com/haveno-dex/haveno-meta/721e52919b28b44d12b6e1e5dac57265f1c05cda/logo/haveno_logo_landscape.svg" alt="Haveno logo">

  [![Codacy Badge](https://app.codacy.com/project/badge/Grade/505405b43cb74d5a996f106a3371588e)](https://app.codacy.com/gh/haveno-dex/haveno/dashboard)
  ![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/haveno-dex/haveno/build.yml?branch=master)
  ![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)
</div>


Flutter Haveno is a client interface written in dart for the [Haveno](https://www.haveno.com) peer-to-peer (P2P) decentralized exchange. This package provides a seamless way for Flutter developers to integrate Haveno's decentralized trading platform into their mobile and desktop applications through the daemons inuitive gRPC channel.

## Overview

Haveno is an open-source, non-custodial exchange platform that allows users to trade cryptocurrencies privately and securely. Built on the principles of decentralization, Haveno connects buyers and sellers in a peer-to-peer manner, eliminating the need for a centralized authority. The Haveno Flutter package empowers developers to leverage this platform’s capabilities, enabling the creation of private and secure trading experiences within Flutter apps.

## Features of Flutter Haveno but also Haveno as a whole

- **Comprehensive Client Interface**: Offers a complete client interface to interact with Haveno, making it simple to connect, trade, and manage your exchange activities via through both gRPC and Protobuf over-the-wire if you create the TCP connecton.
- **Peer-to-Peer Trading**: Facilitates direct trading between users, providing enhanced privacy and control over your assets.
- **Decentralized Architecture**: Operates without a central server, ensuring that users maintain full control of their data and funds.
- **Cross-Platform Support**: Designed for Flutter, enabling integration with both mobile (iOS, Android) and desktop platforms.
- **Secure & Private**: Uses end-to-end encryption and other privacy-preserving technologies to safeguard user data and transactions.

## Getting Started

To start using the Haveno Flutter package in your Flutter application, check out the detailed documentation and example implementation in the repository.


### Usage

To make good use of the library, make yourself familiar with it's specification at the [Haveno Dart Repo Documentation](https://pub.dev/documentation/haveno/latest/) section of pub.dev. These is the best resource you can use to get familiar, I have also written a beginners guide on how to [start off creating a bot in Haveno using the Dart API](https://kewbit.org/start-developing-with-the-haveno-dart-client/), which you may find useful.

Other topics, covering more on the multi-platform app can be found over at the [Haveno documentation](https://haveno.com/documentation) section there.

## Contributing

Contributions are welcome! If you'd like to contribute to the development of the Haveno Flutter package, please do so from the source location, you'll need to register at [the Haveno apps gitlab server](https://git.haveno.com/), this is where the security and building pipelines will run, before syncing to these repos here on Github.

## License

This package is dual licensed licensed under the AGPLv3 license. See the [LICENSE](LICENSE) file for more details. We are 100% FOSS-driven thanks to the support of the community.

## Additional Resources
You can find more additional resources such as documentation on the new [Haveno website](https://haveno.com/) for anything related to the new apps.
