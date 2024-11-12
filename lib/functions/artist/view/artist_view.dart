import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/core.dart';
import 'package:sangeet/core/skeletions/screen_loading_skeleton.dart';
import 'package:sangeet/core/widgets/blur_image_container.dart';
import 'package:sangeet/core/widgets/media_card.dart';
import 'package:sangeet/core/widgets/play_button.dart';
import 'package:sangeet/core/widgets/split_view_container.dart';
import 'package:sangeet/core/widgets/top_details.dart';
import 'package:sangeet/functions/album/view/album_view.dart';
import 'package:sangeet/functions/artist/controller/artist_controller.dart';
import 'package:sangeet/functions/player/controllers/player_controller.dart';
import 'package:sangeet/functions/song/view/song_view.dart';

class ArtistView extends ConsumerWidget {
  static route(String id) => MaterialPageRoute(
        builder: (context) => ArtistView(
          artistId: id,
        ),
      );

  final String artistId;
  const ArtistView({this.artistId = "", super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ModalRoute.of(context)?.settings.name ?? artistId;
    final controller = ref.watch(playerControllerProvider.notifier);

    return ref.watch(artistByIdProvider(name)).when(
          data: (artist) {
            return BlurImageContainer(
              image: artist.images[2].url,
              child: SplitViewContainer(
                leftChild: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopDetailsContainer(
                      image: artist.images[2].url,
                      subtitle: artist.subtitle,
                      title: artist.name,
                      thirdLine: thirdLines(artist),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            children: [
                              const BackButton(),
                              IconButton(
                                tooltip: "More",
                                onPressed: () {},
                                icon: const Icon(Icons.more_vert_rounded),
                              ),
                            ],
                          ),
                          PlayButton(
                            onPressed: () => controller.runRadio(
                              radioId: artist.id,
                              type: MediaType.artist,
                              prevSongs: artist.topSongs,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: artist.topSongs.length,
                        itemBuilder: (context, index) {
                          final song = artist.topSongs[index];
                          return MediaCard(
                            onDoubleTap: () => controller.runRadio(
                              radioId: song.id,
                              type: MediaType.song,
                              prevSongs: artist.topSongs,
                              playCurrent: true,
                            ),
                            onTap: () => Navigator.of(context).push(
                              SongView.route(song.id),
                            ),
                            // image: song.images[1].url,s
                            title: song.title,
                            subtitle:
                                "${song.label}, ${formatDuration(song.duration)}",
                            explicitContent: song.explicitContent,
                            contextMenu: [
                              ContextMenuButtonConfig(
                                icon: const Icon(Icons.queue_music_rounded),
                                "Add in Queue",
                                onPressed: () =>
                                    controller.addSongToQueue(song: song),
                              ),
                              ContextMenuButtonConfig(
                                icon: const Icon(
                                    Icons.play_circle_filled_rounded),
                                "Play Next",
                                onPressed: () =>
                                    controller.addSongToNext(song: song),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
                rightChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Top Albums.',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: artist.topAlbums.length,
                      itemBuilder: (context, index) {
                        final album = artist.topAlbums[index];
                        return MediaCard(
                          accentColor: album.accentColor,
                          onTap: () => Navigator.of(context)
                              .push(AlbumView.route(album.id)),
                          image: album.images[1].url,
                          title: album.title,
                          subtitle: album.subtitle == ""
                              ? "Language ${album.language}"
                              : album.subtitle,
                          explicitContent: album.explicitContent,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          error: (err, st) => ErrorPage(error: err.toString()),
          loading: () => const ScreenLoading(),
        );
  }

  String thirdLines(artist) => """fans ${formatNumber(artist.fanCount)}
followers ${formatNumber(artist.followersCount)}
Dominant ${artist.dominantLanguage} ${artist.dominantType}
  """;
}
