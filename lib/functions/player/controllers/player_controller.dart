import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sangeet/core/api_provider.dart';
import 'package:sangeet/core/core.dart';
import 'package:sangeet/functions/player/widgets/common.dart';
import 'package:sangeet/functions/settings/controllers/settings_controller.dart';
import 'package:sangeet_api/modules/song/models/song_model.dart';
import 'package:sangeet_api/sangeet_api.dart';

final playerControllerProvider =
    StateNotifierProvider<PlayerController, bool>((ref) {
  return PlayerController(
    settingsController: ref.watch(settingsControllerProvider.notifier),
    api: ref.watch(sangeetAPIProvider),
  );
});

final getAudioPlayer =
    Provider((ref) => ref.watch(playerControllerProvider.notifier).getPlayer);

class PlayerController extends StateNotifier<bool> {
  final SettingsController _settingsController;
  final SangeetAPI _api;

  final _player = AudioPlayer();
  final playlist = ConcatenatingAudioSource(
    useLazyPreparation: true,
    shuffleOrder: DefaultShuffleOrder(
      random: Random(),
    ),
    children: [],
  );

  PlayerController({
    required SettingsController settingsController,
    required SangeetAPI api,
  })  : _settingsController = settingsController,
        _api = api,
        super(false);

  AudioPlayer get getPlayer => _player;
  ConcatenatingAudioSource get getplaylist => playlist;

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  Future<void> runRadio({
    required String radioId,
    required MediaType type,
    VoidCallback? redirect,
  }) async {
    try {
      List<SongModel> songs = [];

      await playlist.clear();
      final quality = await _settingsController.getSongQuality();

      if (type == MediaType.song) {
        final songsObjects = await _api.song.radio(songId: radioId);
        final song = await _api.song.getById(songId: radioId);
        if (songsObjects == null || song == null) {
          throw Error.throwWithStackTrace(
              "Can't load right now", StackTrace.empty);
        }

        songs = [song, ...songsObjects.songs];
      }

      if (type == MediaType.album) {
        final album = await _api.album.getById(albumId: radioId);
        if (album == null) {
          throw Error.throwWithStackTrace("Album not found", StackTrace.empty);
        }
        songs = album.songs;
      }
      if (type == MediaType.playlist) {
        final playlistModel = await _api.playlist.getById(id: radioId);
        if (playlistModel == null) {
          throw Error.throwWithStackTrace(
            "Playlist not found",
            StackTrace.empty,
          );
        }

        songs = playlistModel.songs;
      }

      if (type == MediaType.radio) {
        final radio = await _api.song.radio(songId: radioId, featured: true);
        if (radio == null) {
          throw Error.throwWithStackTrace(
            "Radio not found",
            StackTrace.empty,
          );
        }
        songs = radio.songs;
      }

      for (var i = 0; i < songs.length; i++) {
        final uri = songs[i]
            .urls
            .where((element) => element.quality == quality.name)
            .toList()[0]
            .url;

        final accentColor = await ColorScheme.fromImageProvider(
          provider: NetworkImage(songs[i].images[0].url),
          brightness: Brightness.dark,
        );

        final song = songs[i].copyWith(
          accentColor: accentColor.background,
        );

        playlist.add(AudioSource.uri(
          Uri.parse(uri),
          tag: song,
        ));
      }

      await _player.setAudioSource(playlist, preload: true);

      redirect?.call();
      await _player.play();
    } on PlayerException catch (e) {
      if (kDebugMode) {
        print("Error message: ${e.message}");
      }
    } on PlayerInterruptedException catch (e) {
      if (kDebugMode) {
        print("Connection aborted: ${e.message}");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }
}
