import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/size_config.dart';

class ToolbarItem extends StatelessWidget {
  const ToolbarItem({
    super.key,
    required this.icon,
    this.onPressedButton,
    this.tooltip,
    this.isExpandable = false,
    this.items,
  });

  final dynamic icon;
  final VoidCallback? onPressedButton;
  final String? tooltip;
  final bool isExpandable;
  final List? items;

  @override
  Widget build(BuildContext context) {
    return !isExpandable
        ? Material(
            type: MaterialType.transparency,
            child: IconButton(
              onPressed: onPressedButton,
              icon: icon is String
                  ? Text(
                      icon,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 16,
                    ),
              tooltip: tooltip,
            ),
          )
        : ExpandableNotifier(
            child: Expandable(
              key: const Key("list_button"),
              collapsed: ExpandableButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: icon is String
                      ? Text(
                          icon,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : Icon(
                          icon,
                          size: 16,
                        ),
                ),
              ),
              expanded: Container(
                color: AppColors.secondary,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      for (var item in items!) item,
                      ExpandableButton(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Icon(
                            FontAwesomeIcons.solidTimesCircle,
                            size: AppSpacing.iconSizeLg,
                            color: AppColors.destructive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
