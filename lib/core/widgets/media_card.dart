import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:sangeet/core/core.dart';
import 'cache_image.dart';

class MediaCard extends StatelessWidget {
  final String? image;
  final String title;
  final String subtitle;
  final IconData? badgeIcon;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onMenuTap;
  final bool showMenu;
  final bool explicitContent;
  final Color? accentColor;
  final List<ContextMenuButtonConfig?> contextMenu;
  const MediaCard({
    super.key,
    required this.onTap,
    this.image,
    this.accentColor,
    required this.title,
    required this.subtitle,
    this.badgeIcon,
    required this.explicitContent,
    this.onDoubleTap,
    this.contextMenu = const [],
    this.onMenuTap,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: accentColor,
      child: ContextMenuRegion(
        contextMenu: GenericContextMenu(
          buttonStyle: ContextMenuButtonStyle(
            hoverBgColor: Colors.teal.shade100,
            hoverFgColor: Colors.black,
          ),
          buttonConfigs: contextMenu,
        ),
        child: InkWell(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image != null)
                      (Badge(
                        isLabelVisible: badgeIcon != null,
                        backgroundColor:
                            explicitContent ? Colors.redAccent : Colors.teal,
                        label: Icon(
                          badgeIcon,
                          size: 10,
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            topLeft: Radius.circular(8),
                          ),
                          child: CacheImage(
                            url: image!,
                            width: 60,
                            height: 60,
                          ),
                        ),
                      )),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              softWrap: true,
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                overflow: TextOverflow.fade,
                              ),
                              maxLines: 1,
                              softWrap: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: showMenu,
                child: PopupMenuButton(
                  tooltip: "Options",
                  onSelected: (value) {},
                  itemBuilder: (BuildContext context) {
                    return popMenuActions.map((PopMenuAction choice) {
                      return PopupMenuItem<String>(
                        value: choice.value,
                        child: Text(choice.label),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
