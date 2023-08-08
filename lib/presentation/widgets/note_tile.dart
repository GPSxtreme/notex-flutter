import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/note_model.dart';

import '../styles/app_styles.dart';
import '../styles/size_config.dart';

// ignore: must_be_immutable
class NoteTile extends StatefulWidget {
  NoteTile(
      {super.key,
      required this.note});

  final NoteModel note;
  // final Animation<double> animation;
  // final Function() onLongPress;
  // final Function(bool isSelected) onSelect;
  // final bool isInEditMode;
  // late bool isSelected;

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      decoration: BoxDecoration(
          color: kPinkD2,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(width: 1.0, color: kPinkD1)),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          splashColor: kPink,
          borderRadius: BorderRadius.circular(20.0),
          // onLongPress: widget.onLongPress,
          onTap: (){
            // if(widget.isInEditMode){
            //   widget.onSelect(!widget.isSelected);
            //   setState(() {
            //     widget.isSelected = !widget.isSelected;
            //   });
            // }
          },
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.star_border,color: kPink,), onPressed: () {  },
                  color: kWhite,
                  splashRadius: 15,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical! * 2,horizontal: SizeConfig.blockSizeHorizontal! * 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.note.title,
                      style: kInter.copyWith(color: kWhite,fontSize: 20),
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical! * 0.5),
                    Text(
                      widget.note.body,
                      style: kInter.copyWith(color: kWhite24,fontSize: 16),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2,
                    ),
                    Text(
                      'created on : ${DateFormat('d MMMM, h:mm a').format(widget.note.createdTime).toString()}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 12),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 0.5,
                    ),
                    Text(
                      'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.note.editedTime).toString()}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 12),
                    ),
                    Text(
                      'is synced : ${widget.note.isSynced}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
