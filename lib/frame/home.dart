import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:sangeet/core/widgets/blur_image_container.dart';
import 'package:sangeet/functions/player/views/current_playing_view.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

import 'package:sangeet/core/constants.dart';
import 'package:sangeet/functions/explore/views/explore_view.dart';
import 'package:sangeet/functions/player/controllers/player_controller.dart';
import 'package:sangeet/functions/player/widgets/base_audio_player.dart';
import 'package:sangeet/functions/search/views/search_view.dart';
import 'package:sangeet/functions/settings/views/settings_view.dart';
import 'package:sangeet/functions/shortcuts/actions.dart';

import '../core/app_config.dart';

class HomeFrame extends ConsumerStatefulWidget {
  const HomeFrame({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeFrameState();
}

class _HomeFrameState extends ConsumerState<HomeFrame>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);

    FlutterDiscordRPC.instance.connect().catchError((e) {
      debugPrint('Failed To Connect Discord');
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    FlutterDiscordRPC.instance.disconnect();
    FlutterDiscordRPC.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(appScreenConfigProvider);
    final config = ref.watch(appScreenConfigProvider.notifier);
    final player = ref.watch(playerControllerProvider.notifier).getPlayer;

    return Actions(
      actions: <Type, Action<Intent>>{
        BaseIntent: SongActions(
          audioPlayer: player,
        )
      },
      child: GlobalShortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.keyW, alt: true): BaseIntent(
            keyAction: KeyAction.playPauseMusic,
          ),
          SingleActivator(LogicalKeyboardKey.keyD, alt: true): BaseIntent(
            keyAction: KeyAction.nextTrack,
          ),
          SingleActivator(LogicalKeyboardKey.keyA, alt: true): BaseIntent(
            keyAction: KeyAction.prevTrack,
          ),
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlurImageContainer(
            child: Row(
              children: [
                NavigationRail(
                  selectedIndex: index,
                  onDestinationSelected: (idx) => config.onIndex(idx),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text("Home"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text("Search"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.music_note_rounded),
                      label: Text("Current Playing"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings),
                      label: Text("Settings"),
                    ),
                  ],
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'assets/app_icon.ico',
                      width: 35,
                    ),
                  ),
                  labelType: NavigationRailLabelType.none,
                  backgroundColor: Colors.black,
                  indicatorColor: Colors.grey.shade900,
                  unselectedIconTheme: const IconThemeData(color: Colors.grey),
                  selectedIconTheme: const IconThemeData(color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: IndexedStack(
                          index: index,
                          children: [
                            _buildNavigator(
                              0,
                              const ExploreView(),
                            ),
                            _buildNavigator(
                              1,
                              const SearchView(),
                            ),
                            _buildNavigator(
                              2,
                              const CurrentPlayingView(),
                            ),
                            _buildNavigator(
                              3,
                              const SettingsView(),
                            ),
                          ],
                        ),
                      ),
                      const BaseAudioPlayer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigator(int index, Widget child) {
    return Navigator(
      key: GlobalKey<NavigatorState>(debugLabel: 'navigator$index'),
      onGenerateRoute: (settings) => MaterialPageRoute(
        builder: (context) => child,
      ),
    );
  }

  @override
  void onTrayIconRightMouseDown() async {
    await trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    final player = ref.watch(playerControllerProvider.notifier).getPlayer;
    if (menuItem.key == SystemTrayActions.hideShow) {
      if (await windowManager.isVisible()) {
        await windowManager.hide();
      } else {
        await windowManager.show();
      }
    }
    if (menuItem.key == SystemTrayActions.exit) {
      await windowManager.destroy();
    }
    if (menuItem.key == SystemTrayActions.playPauseMusic) {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    }
    if (player.playing) {
      if (menuItem.key == SystemTrayActions.nextTrack) {
        await player.seekToNext();
      }
      if (menuItem.key == SystemTrayActions.prevTrack) {
        await player.seekToPrevious();
      }
      if (menuItem.key == SystemTrayActions.openPlaylist) {
        await windowManager.show();
      }
    }

    super.onTrayMenuItemClick(menuItem);
  }

  @override
  void onWindowClose() async {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          elevation: 0,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('Close this window?'),
          content: const Text('Are you sure you want to close this window?'),
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hide'),
              onPressed: () async {
                Navigator.of(context).pop();
                await windowManager.hide();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () async {
                Navigator.of(context).pop();
                await windowManager.destroy();
              },
            ),
          ],
        );
      },
    );
  }
}
