import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sangeet_api/models.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

void hideKeyboard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

void unfocusKeyboard(context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus) {
    currentFocus.unfocus();
  }
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

String formatNumber(int value) {
  final formatter = NumberFormat.compact(locale: "en_US", explicitSign: false);
  return formatter.format(value);
}

String formatDuration(int value) {
  Duration duration = Duration(seconds: value);
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$twoDigitMinutes:$twoDigitSeconds";
}

List<TrendClass> mergeAllMediaForSearch(SearchTopQueryModel data) {
  final lis = [
    ...data.albums.map(
      (album) => TrendClass(
        id: album.id,
        type: album.type,
        image: album.images[1].url,
        title: album.title,
        subtitle: album.description,
        badgeIcon: Icons.album_rounded,
        explicitContent: album.explicitContent,
        position: 0,
      ),
    ),
    ...data.songs.map(
      (song) => TrendClass(
        id: song.id,
        type: song.type,
        image: song.images[1].url,
        title: song.title,
        subtitle: song.description,
        badgeIcon: Icons.music_note_rounded,
        explicitContent: song.explicitContent,
        position: song.ctr,
      ),
    ),
    ...data.playlists.map(
      (playlist) => TrendClass(
        id: playlist.id,
        type: playlist.type,
        image: playlist.images[1].url,
        title: playlist.title,
        subtitle: playlist.description,
        badgeIcon: Icons.playlist_play_rounded,
        explicitContent: playlist.explicitContent,
        position: 0,
      ),
    ),
    ...data.artists.map(
      (artist) => TrendClass(
        id: artist.id,
        type: artist.type,
        image: artist.images[1].url,
        title: artist.title,
        subtitle: artist.description,
        badgeIcon: Icons.mic_external_on_rounded,
        explicitContent: false,
        position: artist.position,
      ),
    ),
  ];

  lis.shuffle();

  return lis;
}

class TrendClass {
  final String type;
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final IconData badgeIcon;
  final bool explicitContent;
  final Color? accentColor;
  final int position;

  TrendClass({
    required this.image,
    required this.position,
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.badgeIcon,
    required this.explicitContent,
    this.accentColor,
  });
}

class PopMenuAction {
  final String label;
  final String value;

  PopMenuAction({
    required this.label,
    required this.value,
  });
}

List<PopMenuAction> popMenuActions = [
  PopMenuAction(label: 'Play', value: 'play'),
  PopMenuAction(label: 'Save to Playlist', value: 'save_playlist'),
  PopMenuAction(label: 'Add to queue', value: 'queue'),
  PopMenuAction(label: 'Download', value: 'downlaod'),
];
