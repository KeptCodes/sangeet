import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet_api/models.dart';
import 'package:sangeet_api/sangeet_api.dart';

final songControllerProvider =
    StateNotifierProvider<SongController, bool>((ref) {
  return SongController(
    api: ref.watch(sangeetAPIProvider),
  );
});

final songByIdProvider =
    FutureProvider.family<SongModel, String>((ref, String id) async {
  return ref.watch(songControllerProvider.notifier).fetchSongById(songId: id);
});

class SongController extends StateNotifier<bool> {
  final SangeetAPI _api;
  SongController({required SangeetAPI api})
      : _api = api,
        super(false);

  Future<SongModel> fetchSongById({required String songId}) async {
    final song = await _api.song.getById(songId: songId);

    if (song == null) {
      throw Error.throwWithStackTrace("Song not found", StackTrace.empty);
    }
    final accentColor = await ColorScheme.fromImageProvider(
      provider: NetworkImage(song.images[0].url),
      brightness: Brightness.dark,
    );

    final s = song.copyWith(
      accentColor: accentColor.surface,
    );

    return s;
  }

  // Future<List<SongModel>>
}
