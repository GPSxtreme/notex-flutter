import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_styles.dart';


class CommonWidgets{
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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
        backgroundColor: kPinkD2,
        title: Text(
          title,
          style: kInter.copyWith(
              color: titleColor ?? kWhite,
              fontSize: 18,
              fontWeight: FontWeight.w400),
        ),
        content: Text(
          body,
          style: kInter.copyWith(
              color: titleColor ?? kWhite,
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      agreeLabel,
                      style: kInter.copyWith(
                          color: titleColor ?? kPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              if(!isSingleBtn) ...[
                Divider(
                  color: kWhite.withOpacity(0.3),
                  indent: 20,
                  endIndent: 20,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        denyLabel,
                        style: kInter.copyWith(
                            color: titleColor ?? kWhite,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(
                height: 10,
              )
            ],
          ),
        ],
      ),
    );
  }

}
