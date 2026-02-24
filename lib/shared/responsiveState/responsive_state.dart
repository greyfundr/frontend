import 'package:flutter/material.dart';

import 'view_state.dart';

class ResponsiveState extends StatelessWidget {
  final ViewState state;
  final Widget ? idleWidget;
  final Widget? busyWidget;
  final Widget? dataFetchedWidget;
  final Widget? noDataAvailableWidget;
  final Widget? errorWidget;
  final Widget? successWidget;
  final Widget? waitingForInputWidget;

  // returns a widget based on the provided ViewState
  const ResponsiveState({
    super.key,
    required this.state,
    this.idleWidget,
    this.busyWidget,
    this.errorWidget,
    this.dataFetchedWidget,
    this.noDataAvailableWidget,
    this.successWidget,
    this.waitingForInputWidget,
  });
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.Idle:
        return idleWidget  ?? SizedBox.shrink();
      case ViewState.Busy:
        return busyWidget ?? SizedBox.shrink();
      case ViewState.DataFetched:
        return dataFetchedWidget ?? SizedBox.shrink();
      case ViewState.NoDataAvailable:
        return noDataAvailableWidget ?? SizedBox.shrink();
      case ViewState.Error:
        return errorWidget ?? SizedBox.shrink();
      case ViewState.Success:
        return successWidget ?? SizedBox.shrink();
      default:
        return SizedBox.shrink();
    }
  }
}

class ResponsiveStateFunction extends StatelessWidget {
  final ViewState state;
  final Widget Function() onIdle;
  final Widget Function()? onBusy;
  final Widget Function()? onDataFetched;
  final Widget Function()? onNoDataAvailable;
  final Widget Function()? onError;
  final Widget Function()? onSuccess;
  final Widget Function()? onWaitingForInput;

  const ResponsiveStateFunction({
    super.key,
    required this.state,
    required this.onIdle,
    this.onBusy,
    this.onDataFetched,
    this.onNoDataAvailable,
    this.onError,
    this.onSuccess,
    this.onWaitingForInput,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.Idle:
        return onIdle();
      case ViewState.Busy:
        return onBusy?.call() ?? onIdle();
      case ViewState.DataFetched:
        return onDataFetched?.call() ?? onIdle();
      case ViewState.NoDataAvailable:
        return onNoDataAvailable?.call() ?? onIdle();
      case ViewState.Error:
        return onError?.call() ?? onIdle();
      case ViewState.Success:
        return onSuccess?.call() ?? onIdle();
      case ViewState.WaitingForInput:
        return onWaitingForInput?.call() ?? onIdle();
      default:
        return onIdle();
    }
  }
}
