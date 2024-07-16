import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';

class CommonWidgets {
  static Future<bool?> commonAlertDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String agreeLabel,
    required String denyLabel,
    bool isSingleBtn = false,
    bool isBarrierDismissible = true,
    Color? agreeButtonColor,
    Color? denyButtonColor,
    Color? titleColor,
    Color? bodyColor,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: isBarrierDismissible,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
        contentPadding: EdgeInsets.all(AppSpacing.lg),
        actionsPadding: EdgeInsets.zero,
        title: Text(title,
            style: AppText.textXlSemiBold
                .copyWith(color: titleColor ?? AppColors.foreground)),
        content: Text(
          body,
          style: AppText.textBase
              .copyWith(color: bodyColor ?? AppColors.foreground),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.maxFinite,
                    child: Center(
                      child: Text(agreeLabel,
                          style: AppText.textBaseMedium.copyWith(
                              color: agreeButtonColor ?? AppColors.primary)),
                    ),
                  ),
                ),
              ),
              if (!isSingleBtn) ...[
                const Divider(
                  color: AppColors.border,
                  height: 10,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      width: double.maxFinite,
                      child: Center(
                        child: Text(denyLabel,
                            style: AppText.textBaseMedium.copyWith(
                                color:
                                    denyButtonColor ?? AppColors.foreground)),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(
                height: AppSpacing.sm,
              )
            ],
          ),
        ],
      ),
    );
  }
}
