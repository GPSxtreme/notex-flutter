import 'package:flutter/material.dart';
import 'package:notex/external/simpleMarkdown/emoji_parser.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';

class ModalSelectEmoji extends StatefulWidget {
  const ModalSelectEmoji({
    super.key,
    this.onChanged,
    this.emojiConvert = true,
  });

  final bool emojiConvert;
  final ValueChanged<String>? onChanged;

  @override
  ModalSelectEmojiState createState() => ModalSelectEmojiState();
}

class ModalSelectEmojiState extends State<ModalSelectEmoji> {
  final _parser = EmojiParser();

  String _search = "";
  final List<String> _emoticons = [
    ":blush:",
    ":smirk:",
    ":kissing_closed_eyes:",
    ":satisfied:",
    ":stuck_out_tongue_winking_eye:",
    ":kissing:",
    ":sleeping:",
    ":anguished:",
    ":confused:",
    ":unamused:",
    ":disappointed_relieved:",
    ":disappointed:",
    ":cold_sweat:",
    ":sob:",
    ":scream:",
    ":angry:",
    ":sleepy:",
    ":sunglasses:",
    ":innocent:",
    ":smiley:",
    ":heart_eyes:",
    ":flushed:",
    ":grin:",
    ":stuck_out_tongue_closed_eyes:",
    ":kissing_smiling_eyes:",
    ":worried:",
    ":open_mouth:",
    ":hushed:",
    ":sweat_smile:",
    ":weary:",
    ":confounded:",
    ":persevere:",
    ":joy:",
    ":rage:",
    ":yum:",
    ":dizzy_face:",
    ":neutral_face:",
    ":relaxed:",
    ":kissing_heart:",
    ":relieved:",
    ":wink:",
    ":grinning:",
    ":stuck_out_tongue:",
    ":frowning:",
    ":grimacing:",
    ":expressionless:",
    ":sweat:",
    ":pensive:",
    ":fearful:",
    ":cry:",
    ":astonished:",
    ":tired_face:",
    ":triumph:",
    ":mask:",
    ":no_mouth:",
    ":heart:",
    ":broken_heart:",
    ":star:",
    ":star2:",
    ":exclamation:",
    ":question:",
    ":fire:",
    ":shit:",
    ":thumbsup:",
    ":thumbsdown:",
    ":punch:",
    ":raised_hands:",
    ":clap:",
    ":pray:",
    ":ok_hand:",
    ":muscle:",
    ":dash:",
    ":zzz:",
    ":sweat_drops:",
    ":wave:",
    ":point_up:",
    ":point_down:",
    ":point_left:",
    ":point_right:",
    ":x:",
    ":white_check_mark:",
    ":negative_squared_cross_mark:",
    ":100:",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Emoticons",
            style: AppText.text2XlBold,
          ),
          SizedBox(
            height: AppSpacing.md,
          ),
          TextField(
            onChanged: (String value) {
              _search = value;
              setState(() {});
            },
            decoration: InputDecoration(
                hintText: 'Search emoji..',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.mutedForeground,
                  size: AppSpacing.iconSizeBase,
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.2,
            ),
            child: _listEmotes(context),
          ),
        ],
      ),
    );
  }

  Widget _listEmotes(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        padding: EdgeInsets.zero,
        itemCount: _emoticons
            .where((element) =>
                element.toLowerCase().contains(_search.toLowerCase()))
            .length,
        itemBuilder: (context, index) {
          var emote = _emoticons
              .where((element) =>
                  element.toLowerCase().contains(_search.toLowerCase()))
              .elementAt(index);

          return TextButton(
            key: ValueKey<String>("${index}_${emote.replaceAll(":", "")}"),
            onPressed: () {
              widget.onChanged?.call(
                (widget.emojiConvert) ? _parser.emojify(emote) : emote,
              );
            },
            child: Text(
              _parser.emojify(emote),
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _emoticons.clear();
    super.dispose();
  }
}
