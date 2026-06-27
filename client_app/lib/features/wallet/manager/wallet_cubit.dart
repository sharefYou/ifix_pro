import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ifix_client/core/api/api_constants.dart';
import 'package:ifix_client/core/api/dio_helper.dart';
import 'package:ifix_client/core/helpers/error_handler.dart';
import '../data/models/wallet_model.dart';
import 'wallet_states.dart';

class WalletCubit extends Cubit<WalletStates> {
  WalletCubit() : super(WalletInitialState());

  WalletModel? currentWallet;
  List<WalletTransactionModel> transactions = [];

  Future<void> fetchWalletData() async {
    emit(WalletLoadingState());
    try {
      final balRes = await DioHelper.getData(endPoint: ApiConstants.walletBalance);
      currentWallet = WalletModel.fromJson(balRes.data['data']);

      final transRes = await DioHelper.getData(endPoint: ApiConstants.walletTransactions);
      transactions = [];
      if (transRes.data['data'] is List) {
        for (final item in transRes.data['data']) {
          if (item is Map<String, dynamic>) {
            transactions.add(WalletTransactionModel.fromJson(item));
          }
        }
      }

      emit(WalletLoadedState(wallet: currentWallet!, transactions: transactions));
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(WalletErrorState(error));
    }
  }

  Future<void> topUpWallet(String code) async {
    emit(TopUpLoadingState());
    try {
      final response = await DioHelper.postData(
        endPoint: ApiConstants.walletTopUp,
        data: {'code': code},
      );
      emit(TopUpSuccessState(response.data['message']?.toString() ?? 'تم الشحن بنجاح'));
      await fetchWalletData();
    } catch (e) {
      final error = ErrorHandler.handleGeneralError(e);
      emit(TopUpErrorState(error));
    }
  }
}
