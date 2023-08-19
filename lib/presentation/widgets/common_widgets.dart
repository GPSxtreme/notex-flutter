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
        backgroundColor: kPinkD1,
        title: Text(
          title,
          style: kInter.copyWith(
              color: titleColor ?? kWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        content: Text(
          body,
          style: kInter.copyWith(
              color: titleColor ?? kWhite,
              fontSize: 15,
              fontWeight: FontWeight.w600),
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
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      agreeLabel,
                      style: kInter.copyWith(
                          color: titleColor ?? kPink,
                          fontSize: 16,
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
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        denyLabel,
                        style: kInter.copyWith(
                            color: titleColor ?? kWhite,
                            fontSize: 16,
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
