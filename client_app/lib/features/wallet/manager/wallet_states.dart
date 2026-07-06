import '../data/models/wallet_model.dart';

abstract class WalletStates {}

class WalletInitialState extends WalletStates {}

class WalletLoadingState extends WalletStates {}

class WalletLoadedState extends WalletStates {
  final WalletModel wallet;
  final List<WalletTransactionModel> transactions;
  WalletLoadedState({required this.wallet, required this.transactions});
}

class WalletErrorState extends WalletStates {
  final String error;
  WalletErrorState(this.error);
}

class TopUpLoadingState extends WalletStates {}

class TopUpSuccessState extends WalletStates {
  final String message;
  TopUpSuccessState(this.message);
}

class TopUpErrorState extends WalletStates {
  final String error;
  TopUpErrorState(this.error);
}



