import 'package:flutter/material.dart';

class MediaCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final IconData? badgeIcon;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onMenuTap;
  final bool showMenu;
  final bool explicitContent;
  final Color? accentColor;
  const MediaCard({
    super.key,
    required this.onTap,
    required this.image,
    this.accentColor,
    required this.title,
    required this.subtitle,
    this.badgeIcon,
    required this.explicitContent,
    this.onDoubleTap,
    this.onMenuTap,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: accentColor,
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
                  Badge(
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
                      child: Image.network(
                        image,
                        width: 60,
                        height: 60,
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(Icons.error_outline_rounded),
                          );
                        },
                      ),
                    ),
                  ),
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
              child: IconButton(
                tooltip: "Options",
                onPressed: onMenuTap ?? () {},
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}