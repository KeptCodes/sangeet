import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet_api/models.dart';
import 'package:sangeet_api/sangeet_api.dart';

final chartControllerProvider =
    StateNotifierProvider<ChartController, bool>((ref) {
  return ChartController(
    api: ref.watch(sangeetAPIProvider),
  );
});

final chartByIdProvider =
    FutureProvider.family<PlaylistModel, String>((ref, String token) async {
  return ref
      .watch(chartControllerProvider.notifier)
      .fetchChartById(token: token);
});

class ChartController extends StateNotifier<bool> {
  final SangeetAPI _api;
  ChartController({required SangeetAPI api})
      : _api = api,
        super(false);

  Future<PlaylistModel> fetchChartById({required String token}) async {
    final chart = await _api.explore.chart(token: token);

    if (chart == null) {
      throw Error.throwWithStackTrace("Chart not found", StackTrace.empty);
    }
    final accentColor = await ColorScheme.fromImageProvider(
      provider: NetworkImage(chart.images[0].url),
      brightness: Brightness.dark,
    );

    final s = chart.copyWith(
      accentColor: accentColor.surface,
    );

    return s;
  }
}
