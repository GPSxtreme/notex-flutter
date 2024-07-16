import 'package:flutter/material.dart';
import 'package:notex/external/simpleMarkdown/toolbar.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';

class ModalInputUrl extends StatelessWidget {
  const ModalInputUrl({
    super.key,
    required this.toolbar,
    required this.leftText,
    required this.selection,
  });

  final Toolbar toolbar;
  final String leftText;
  final TextSelection selection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Please provide valid image URL",
            style: AppText.textBaseMedium.copyWith(color: AppColors.foreground),
          ),
          SizedBox(
            height: AppSpacing.md,
          ),
          TextField(
            decoration: const InputDecoration(
              hintText: "https://example.com",
            ),
            onSubmitted: (String value) {
              Navigator.pop(context);

              /// check if the user entered an empty input
              if (value.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      "https://example.com",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.red.withOpacity(0.8),
                    duration: const Duration(milliseconds: 700),
                  ),
                );
              } else {
                if (!value.contains(RegExp(r'https?:\/\/(www.)?([^\s]+)'))) {
                  value = "http://" + value;
                }
                toolbar.action(
                  "$leftText$value)",
                  "",
                  textSelection: selection,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
