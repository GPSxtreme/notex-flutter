import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import '../../router/app_route_constants.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';

// ignore: must_be_immutable
class NoteTile extends StatefulWidget {
  const NoteTile({super.key, required this.note, required this.notesBloc});

  final NoteModel note;
  final NotesBloc notesBloc;

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
          onTap: () {
            GoRouter.of(context).pushNamed(AppRouteConstants.noteViewRouteName,
                pathParameters: {'noteId': widget.note.id},
                extra: widget.notesBloc);
          },
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.star_border, color: kWhite),
                  onPressed: () {},
                  splashRadius: 15,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical! * 2,
                  horizontal: SizeConfig.blockSizeHorizontal! * 5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 3,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          // Add Flexible widget here
                          child: Text(
                            widget.note.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: kInter.copyWith(color: kWhite, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.blockSizeVertical! * 0.5),
                    Text(
                      widget.note.body,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                      style: kInter.copyWith(color: kWhite24, fontSize: 12),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 2,
                    ),
                    Text(
                      'created on : ${DateFormat('d MMMM, h:mm a').format(widget.note.createdTime).toString()}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 10),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeVertical! * 0.5,
                    ),
                    Text(
                      'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.note.editedTime).toString()}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 10),
                    ),
                    Text(
                      'is synced : ${widget.note.isSynced}',
                      style: kInter.copyWith(color: kWhite75, fontSize: 10),
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
