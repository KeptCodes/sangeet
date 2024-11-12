import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet_api/models.dart';
import 'package:sangeet_api/sangeet_api.dart';

final playlistControllerProvider =
    StateNotifierProvider<PlaylistController, bool>((ref) {
  return PlaylistController(
    api: ref.watch(sangeetAPIProvider),
  );
});

final playlistByIdProvider =
    FutureProvider.family<PlaylistModel, String>((ref, String id) async {
  return ref
      .watch(playlistControllerProvider.notifier)
      .fetchPlaylistById(playlistId: id);
});

class PlaylistController extends StateNotifier<bool> {
  final SangeetAPI _api;
  PlaylistController({required SangeetAPI api})
      : _api = api,
        super(false);

  Future<PlaylistModel> fetchPlaylistById({required String playlistId}) async {
    final playlist = await _api.playlist.getById(id: playlistId);

    if (playlist == null) {
      throw Error.throwWithStackTrace("Playlist not found", StackTrace.empty);
    }
    final accentColor = await ColorScheme.fromImageProvider(
      provider: NetworkImage(playlist.images[0].url),
      brightness: Brightness.dark,
    );

    final s = playlist.copyWith(
      accentColor: accentColor.surface,
    );

    return s;
  }
}
