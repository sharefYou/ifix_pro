import '../data/models/user_model.dart';

abstract class ProfileStates {}

class ProfileInitialState extends ProfileStates {}

class ProfileLoadingState extends ProfileStates {}

class ProfileLoadedState extends ProfileStates {
  final UserModel user;
  ProfileLoadedState(this.user);
}

class ProfileErrorState extends ProfileStates {
  final String error;
  ProfileErrorState(this.error);
}

class ProfileUpdateLoadingState extends ProfileStates {}

class ProfileUpdateSuccessState extends ProfileStates {
  final UserModel user;
  ProfileUpdateSuccessState(this.user);
}

class ProfileUpdateErrorState extends ProfileStates {
  final String error;
  ProfileUpdateErrorState(this.error);
}
