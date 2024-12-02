import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet_api/models.dart';
import 'package:sangeet_api/sangeet_api.dart';

final artistControllerProvider =
    StateNotifierProvider<ArtistController, bool>((ref) {
  return ArtistController(
    api: ref.watch(sangeetAPIProvider),
  );
});

final artistByIdProvider =
    FutureProvider.family<ArtistModel, String>((ref, String token) async {
  return ref
      .watch(artistControllerProvider.notifier)
      .fetchArtistById(artistId: token);
});

class ArtistController extends StateNotifier<bool> {
  final SangeetAPI _api;
  ArtistController({required SangeetAPI api})
      : _api = api,
        super(false);

  Future<ArtistModel> fetchArtistById({required String artistId}) async {
    final artist = await _api.artist.getById(artistId: artistId);
    if (artist == null) {
      throw Error.throwWithStackTrace("Artist not found", StackTrace.empty);
    }
    final accentColor = await ColorScheme.fromImageProvider(
      provider: NetworkImage(artist.images[0].url),
      brightness: Brightness.dark,
    );

    final s = artist.copyWith(
      accentColor: accentColor.surface,
    );

    return s;
  }
}
