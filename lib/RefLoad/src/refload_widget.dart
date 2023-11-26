import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class RefLoad extends StatefulWidget {
  //[RefLoad]
  /// ***Refresh And LoadMore***
  ///
  /// Widget That Can handle Refresh and Loadmore. very very basic of widget combination.
  ///
  /// Only support **SLIVER SCROLLABLE WIDGET**.
  ///
  ///
  /// *IMPORTANT NOTE !*
  ///
  /// This widget should be a parent widget for any scrollable widget,
  ///
  /// Because this return a notificationListener than wrapping Customscrollview,
  ///
  /// So place this widget directly body of Scaffold, or something widget that wrapping
  ///
  /// all scrollable widget. otherwise posible bug. :-/
  ///
  /// LoadMore trigger when exceed edge of end scroll and detect scoll direction,
  ///
  /// sometimes if you too fast swipe up for loadmore, that loadMore Callback
  ///
  /// not executed , because there is a millisecond for engine in flutter
  ///
  /// that detect on edge of scroll depend on user scroll interaction,
  ///
  /// this is what i found, but i dont know the right explanation for this.
  const RefLoad({
    super.key,
    required this.onRefresh,
    required this.onLoadMore,
    required this.slivers,
    this.onLoadMoreWidget,
    this.refreshWidgetBuilder,
    this.isCanLoadMore = false,
    this.isCanRefresh = true,
    this.scrollController,
  });

  ///[onRefresh]
  /// Async Function Callback when Refresh Triggered.
  final Future<void> Function() onRefresh;

  ///[onLoadMore]
  /// Async Function Callback when LoadMore Triggered.
  final Future<void> Function() onLoadMore;

  ///[slivers]
  /// List of Sliver Widget that must scrollable.
  ///
  /// Throw error if not pass sliver widget.
  ///
  /// Usually this widget is UI state widget that always change.
  final List<Widget> slivers;

  ///[onLoadMoreWidget]
  /// Widget that appear while Callback loadmore triggered.
  /// You can add any type of widget for loadmore widget.
  ///
  /// If you define your own [onLoadMoreWidget] than you have to manage your widget for loadmore widget state.
  ///
  /// because if you dont specify your own, then widget and state is manage internally.
  final Widget? onLoadMoreWidget;

  ///[refreshWidgetBuilder]
  /// Widget builder for manage showing widget depend on refresh status.
  ///
  /// Default handle internally by [RefLoad] widget.

  final RefreshWidgetBuilder? refreshWidgetBuilder;

  ///[isCanLoadMore]
  ///  disable loadMore.
  final bool? isCanLoadMore;

  ///[isCanRefresh]
  ///  disable loadMore.
  final bool? isCanRefresh;

  ///
  final ScrollController? scrollController;

  @override
  State<RefLoad> createState() => _RefLoadState();
}

class _RefLoadState extends State<RefLoad> {
  final ValueNotifier<bool> _onLoadMoreInternal = ValueNotifier(false);

  @override
  void dispose() {
    _onLoadMoreInternal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final internalLoadMoreWidget = ValueListenableBuilder(
      valueListenable: _onLoadMoreInternal,
      builder: (_, loadmore, __) => _onLoadMoreInternal.value
          ? const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: CupertinoActivityIndicator(
                radius: 12,
              ),
            )
          : const SizedBox.shrink(),
    );

    final List<Widget> internalSlivers = [
      CupertinoSliverRefreshControl(
        builder: widget.refreshWidgetBuilder ?? _refreshControlBuilder,
        //onRefresh callbak not executed is isCanRefresh == false
        onRefresh: widget.isCanRefresh! ? widget.onRefresh : null,
      ),
      SliverToBoxAdapter(
          child: widget.onLoadMoreWidget ?? internalLoadMoreWidget),
    ];

    // inserting new slivers from slivers variable
    internalSlivers.insertAll(1, widget.slivers);

    return NotificationListener<UserScrollNotification>(
      onNotification: (e) {
        // Handle Trigger LoadMore CallBack
        if (e.metrics.atEdge &&
            e.direction == ScrollDirection.reverse &&
            e.metrics.extentAfter == 0.0) {
          //loadmore callbak not executed is isCanLoadMore == false
          if (widget.isCanLoadMore!) {
            if (widget.onLoadMoreWidget != null) {
              _onLoadMoreInternal.value = true;
            }
            widget.onLoadMore.call().then((_) {
              if (widget.onLoadMoreWidget != null) {
                _onLoadMoreInternal.value = false;
              }
            });
          }
        }
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: internalSlivers,
      ),
    );
  }

  Widget _refreshControlBuilder(
    BuildContext context,
    RefreshIndicatorMode mode,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    final double percentageComplete =
        clampDouble(pulledExtent / refreshTriggerPullDistance, 0.0, 1.0);

    if (widget.isCanRefresh!) {
      switch (mode) {
        case RefreshIndicatorMode.drag:
          const Curve opacityCurve =
              Interval(0.0, 0.35, curve: Curves.easeInOut);
          return Opacity(
            opacity: opacityCurve.transform(percentageComplete),
            child: Center(
              child: CupertinoActivityIndicator.partiallyRevealed(
                  radius: 12.0, progress: percentageComplete),
            ),
          );
        case RefreshIndicatorMode.armed:
        case RefreshIndicatorMode.refresh:
          return const Center(
            child: CupertinoActivityIndicator(
              radius: 12.0,
            ),
          );
        case RefreshIndicatorMode.done:
          return Center(
            child: CupertinoActivityIndicator(
              radius: 12.0 * percentageComplete,
            ),
          );
        case RefreshIndicatorMode.inactive:
          return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}

typedef RefreshWidgetBuilder = Widget Function(
  BuildContext context,
  RefreshIndicatorMode refreshState,
  double pulledExtent,
  double refreshTriggerPullDistance,
  double refreshIndicatorExtent,
);
