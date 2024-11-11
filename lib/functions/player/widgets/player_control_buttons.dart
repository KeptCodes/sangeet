import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sangeet/functions/player/controllers/player_controller.dart';
import 'package:sangeet_api/models.dart';
import 'package:smtc_windows/smtc_windows.dart';

class PlayerControllerButtons extends ConsumerWidget {
  final AudioPlayer player;
  const PlayerControllerButtons({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smtc = ref.watch(playerControllerProvider.notifier).getSMTC;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snapshot) {
            final loopMode = snapshot.data ?? LoopMode.off;
            const icons = [
              Icon(Icons.repeat, color: Colors.white),
              Icon(Icons.repeat, color: Colors.teal),
              Icon(Icons.repeat_one, color: Colors.teal),
            ];
            const cycleModes = [
              LoopMode.off,
              LoopMode.all,
              LoopMode.one,
            ];
            final index = cycleModes.indexOf(loopMode);
            return IconButton(
              icon: icons[index],
              onPressed: () {
                player.setLoopMode(cycleModes[
                    (cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: Colors.white,
          ),
          onPressed: () async {
            if (player.previousIndex == null) return;
            SongModel prevSong =
                player.audioSource?.sequence[player.previousIndex ?? 0].tag;
            await smtc.updateMetadata(MusicMetadata(
              title: prevSong.title,
              album: prevSong.albumName,
              thumbnail: prevSong.images[1].url,
              artist: prevSong.artists[0].name,
            ));
            await smtc.setPlaybackStatus(PlaybackStatus.playing);
            await player.seekToPrevious();
          },
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                child: const CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  strokeAlign: -4,
                  color: Colors.teal,
                  strokeWidth: 2,
                ),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  size: 35,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () async {
                  await smtc.setIsPlayEnabled(true);
                  await player.play();
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(
                  Icons.pause_rounded,
                  size: 35,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () async {
                  await smtc.setIsPlayEnabled(false);
                  await player.pause();
                },
              );
            } else {
              return IconButton(
                icon: const Icon(
                  Icons.replay_circle_filled_rounded,
                  size: 35,
                  color: Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                onPressed: () => player.seek(Duration.zero),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            color: Colors.white,
          ),
          onPressed: () async {
            SongModel nextSong = player
                .audioSource
                ?.sequence[player.nextIndex ?? (player.sequence!.length - 1)]
                .tag;
            await smtc.updateMetadata(MusicMetadata(
              title: nextSong.title,
              album: nextSong.albumName,
              thumbnail: nextSong.images[1].url,
              artist: nextSong.artists[0].name,
            ));
            await smtc.setPlaybackStatus(PlaybackStatus.playing);
            await player.seekToNext();
          },
        ),
        StreamBuilder<bool>(
          stream: player.shuffleModeEnabledStream,
          builder: (context, snapshot) {
            final shuffleModeEnabled = snapshot.data ?? false;
            return IconButton(
              icon: shuffleModeEnabled
                  ? const Icon(Icons.shuffle, color: Colors.teal)
                  : const Icon(Icons.shuffle, color: Colors.white),
              onPressed: () async {
                final enable = !shuffleModeEnabled;
                if (enable) {
                  await player.shuffle();
                }
                await player.setShuffleModeEnabled(enable);
              },
            );
          },
        ),
      ],
    );
  }
}
