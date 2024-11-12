import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sangeet/core/widgets/top_details.dart';
import 'package:sangeet/functions/explore/widgets/browse_card.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sangeet/main.dart' as app;

void main() {
  group("e2e Testing", () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Explore Cards Working', (WidgetTester tester) async {
      String mediaName = "";
      String mediaTopName = "";
      Finder backBtn;
      await app.main();
      await tester.pumpAndSettle();

      final albumCard = find.byKey(const Key("album_card_1"));
      mediaName = (albumCard.evaluate().first.widget as BrowseCard).title;
      await tester.ensureVisible(albumCard);
      await tester.tap(albumCard);
      await tester.pumpAndSettle();

      mediaTopName = (find.byKey(const Key("album_top")).evaluate().first.widget
              as TopDetailsContainer)
          .title;

      backBtn = find.byKey(const Key("back_btn"));
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
      expect(mediaTopName, mediaName);

      final chartCard = find.byKey(const Key("chart_card_0"));
      await tester.ensureVisible(chartCard);
      mediaName = (chartCard.evaluate().first.widget as BrowseCard).title;
      await tester.tap(chartCard);
      await tester.pumpAndSettle();

      mediaTopName = (find.byKey(const Key("chart_top")).evaluate().first.widget
              as TopDetailsContainer)
          .title;

      backBtn = find.byKey(const Key("back_btn"));
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
      expect(mediaTopName, mediaName);

      final playlistCard = find.byKey(const Key("playlist_card_0"));
      await tester.ensureVisible(playlistCard);
      mediaName = (playlistCard.evaluate().first.widget as BrowseCard).title;
      await tester.tap(playlistCard);
      await tester.pumpAndSettle();

      mediaTopName = (find
              .byKey(const Key("playlist_top"))
              .evaluate()
              .first
              .widget as TopDetailsContainer)
          .title;

      backBtn = find.byKey(const Key("back_btn"));
      await tester.tap(backBtn);
      await tester.pumpAndSettle();
      expect(mediaTopName, mediaName);
    });
  });
}
