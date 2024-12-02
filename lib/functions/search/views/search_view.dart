import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sangeet/core/core.dart';
import 'package:sangeet/core/widgets/media_card.dart';
import 'package:sangeet/functions/album/view/album_view.dart';
import 'package:sangeet/functions/artist/view/artist_view.dart';
import 'package:sangeet/functions/playlist/view/playlist_view.dart';
import 'package:sangeet/functions/search/controllers/search_controller.dart'
    as c;
import 'package:sangeet/functions/song/view/song_view.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final SearchController _controller = SearchController();

  void search(String q) async {
    await ref.watch(c.searchControllerProvider.notifier).searchSong(query: q);
    ref.invalidate(c.searchDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = [
      'One Love',
      "Love you for thousand years",
      "Sajni re",
      "Shape of you",
    ];

    return Column(
      children: [
        SearchAnchor(
          searchController: _controller,
          builder: (context, controller) {
            return SearchBar(
              controller: controller,
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                // controller.openView();
              },
              onSubmitted: (value) {
                search(value);
              },
              leading: const Icon(Icons.search),
            );
          },
          // viewOnChanged: (value) {
          //   _controller.closeView(value);
          //   search(value);
          // },
          viewOnSubmitted: (value) {
            _controller.closeView(value);
            search(value);
          },
          suggestionsBuilder: (context, controller) {
            return List.from(suggestions.map((item) {
              return ListTile(
                trailing: const Icon(Icons.trending_up_rounded),
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            }));
          },
        ),
        Expanded(
          child: (ref.watch(c.searchDataProvider).when(
                skipLoadingOnRefresh: false,
                data: (result) {
                  if (result == null) {
                    return const Center(
                      child: Text('Search results will be displayed here!'),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Visibility(
                          visible:
                              mergeAllMediaForSearch(result.top).isNotEmpty,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Top Results",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        for (final item in mergeAllMediaForSearch(result.top))
                          MediaCard(
                            onTap: () {
                              if (item.type == 'song') {
                                Navigator.of(context)
                                    .push(SongView.route(item.id));
                              }
                              if (item.type == 'album') {
                                Navigator.of(context)
                                    .push(AlbumView.route(item.id));
                              }
                              if (item.type == 'playlist') {
                                Navigator.of(context)
                                    .push(PlaylistView.route(item.id));
                              }
                              if (item.type == 'artist') {
                                Navigator.of(context)
                                    .push(ArtistView.route(item.id));
                              }
                            },
                            image: item.image,
                            title: item.title,
                            subtitle: item.subtitle,
                            explicitContent: item.explicitContent,
                            badgeIcon: item.badgeIcon,
                            showMenu: false,
                          ),
                        Visibility(
                          visible: result.songs.results.isNotEmpty,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Songs",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        for (final song in result.songs.results)
                          MediaCard(
                            onTap: () => Navigator.of(context)
                                .push(SongView.route(song.id)),
                            image: song.images[1].url,
                            title: song.title,
                            subtitle: song.subtitle,
                            explicitContent: song.explicitContent,
                            badgeIcon: Icons.music_note_rounded,
                            showMenu: false,
                          ),
                        Visibility(
                          visible: result.albums.results.isNotEmpty,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Albums",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        for (final item in result.albums.results)
                          MediaCard(
                            onTap: () => Navigator.of(context)
                                .push(AlbumView.route(item.id)),
                            image: item.images[1].url,
                            title: item.title,
                            subtitle: item.subtitle ?? "",
                            explicitContent: item.explicitContent,
                            badgeIcon: Icons.album_rounded,
                            showMenu: false,
                          ),
                        Visibility(
                          visible: result.artists.results.isNotEmpty,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Artists",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        for (final item in result.artists.results)
                          MediaCard(
                            onTap: () => Navigator.of(context)
                                .push(ArtistView.route(item.id)),
                            image: item.images[1].url,
                            title: item.title,
                            subtitle: "",
                            explicitContent: false,
                            badgeIcon: Icons.mic_external_on_rounded,
                            showMenu: false,
                          ),
                        Visibility(
                          visible: result.playlists.results.isNotEmpty,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Playlists",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        for (final item in result.playlists.results)
                          MediaCard(
                            onTap: () => Navigator.of(context)
                                .push(PlaylistView.route(item.id)),
                            image: item.images[1].url,
                            title: item.title,
                            subtitle: item.subtitle,
                            explicitContent: item.explicitContent,
                            badgeIcon: Icons.album_rounded,
                            showMenu: false,
                          ),
                      ],
                    ),
                  );
                },
                error: (error, st) => ErrorPage(error: error.toString()),
                loading: () => const Loader(),
              )),
        ),
      ],
    );
  }
}
