import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet_api/models.dart';
import 'package:sangeet_api/sangeet_api.dart';

final albumControllerProvider =
    StateNotifierProvider<AlbumController, bool>((ref) {
  return AlbumController(
    api: ref.watch(sangeetAPIProvider),
  );
});

final albumByIdProvider =
    FutureProvider.family<AlbumModel, String>((ref, String id) async {
  return ref
      .watch(albumControllerProvider.notifier)
      .fetchAlbumById(albumId: id);
});

class AlbumController extends StateNotifier<bool> {
  final SangeetAPI _api;
  AlbumController({required SangeetAPI api})
      : _api = api,
        super(false);

  Future<AlbumModel> fetchAlbumById({required String albumId}) async {
    final album = await _api.album.getById(albumId: albumId);

    if (album == null) {
      throw Error.throwWithStackTrace("Album not found", StackTrace.empty);
    }
    final accentColor = await ColorScheme.fromImageProvider(
      provider: NetworkImage(album.images[0].url),
      brightness: Brightness.dark,
    );

    final s = album.copyWith(
      accentColor: accentColor.surface,
    );

    return s;
  }
}
