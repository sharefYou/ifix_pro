import '../data/models/custom_request_model.dart';

abstract class CustomRequestsStates {}

class CustomRequestsInitialState extends CustomRequestsStates {}

class CustomRequestsLoadingState extends CustomRequestsStates {}

class CustomRequestsLoadedState extends CustomRequestsStates {
  final List<CustomRequestModel> requests;
  CustomRequestsLoadedState(this.requests);
}

class CustomRequestsErrorState extends CustomRequestsStates {
  final String error;
  CustomRequestsErrorState(this.error);
}

class CreateCustomRequestLoadingState extends CustomRequestsStates {}

class CreateCustomRequestSuccessState extends CustomRequestsStates {
  final CustomRequestModel request;
  CreateCustomRequestSuccessState(this.request);
}

class CreateCustomRequestErrorState extends CustomRequestsStates {
  final String error;
  CreateCustomRequestErrorState(this.error);
}

class BidsLoadingState extends CustomRequestsStates {}

class BidsLoadedState extends CustomRequestsStates {
  final List<BidModel> bids;
  BidsLoadedState(this.bids);
}

class BidsErrorState extends CustomRequestsStates {
  final String error;
  BidsErrorState(this.error);
}

class AcceptBidLoadingState extends CustomRequestsStates {}

class AcceptBidSuccessState extends CustomRequestsStates {
  final String message;
  AcceptBidSuccessState(this.message);
}

class AcceptBidErrorState extends CustomRequestsStates {
  final String error;
  AcceptBidErrorState(this.error);
}
