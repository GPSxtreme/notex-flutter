import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import '../../router/app_route_constants.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class NoteTile extends StatefulWidget {
  const NoteTile({super.key, required this.note, required this.notesBloc});

  final NoteModel note;
  final NotesBloc notesBloc;

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool _isSelected = false;
  bool _areAllSelected = false;
  bool _isSyncing = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPinkD1;
    }
    return kPinkD1;
  }

  _inEditOnTap() {
    if (_areAllSelected) {
      widget.notesBloc.add(NotesSetAllNotesSelectedCheckBoxEvent(false,isInHiddenMode: widget.note.isHidden));
      _areAllSelected = false;
      if (_areAllSelected && !_isSelected) {
        _isSelected = true;
      } else {
        _isSelected = false;
      }
      widget.notesBloc.add(NotesIsNoteSelectedEvent(_isSelected, widget.note,isInHiddenMode: widget.note.isHidden));
    } else {
      _isSelected = !_isSelected;
      widget.notesBloc.add(NotesIsNoteSelectedEvent(_isSelected, widget.note,isInHiddenMode: widget.note.isHidden));
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: widget.notesBloc,
      buildWhen: (previous, current) => current is! NotesActionState,
      listener: (context, state) {
        if (state is NotesExitedEditingState) {
          _isSelected = false;
          _areAllSelected = false;
        }
      },
      builder: (context, state) {
        if (state is NotesEditingState) {
          if (state.selectedNotesIds != null) {
            state.selectedNotesIds!.contains(widget.note.id)
                ? _isSelected = true
                : _isSelected = false;
          } else {
            _isSelected = false;
            _areAllSelected = false;
          }
          if (!_isSelected && state.areAllSelected) {
            _areAllSelected = true;
          }
        }
        if (state is NotesFetchedState) {
          if (state.syncingNotes != null) {
            if (state.syncingNotes!.contains(widget.note.id)) {
              _isSyncing = true;
            }
          } else {
            _isSyncing = false;
          }
        }
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
              onLongPress: () {
                print('widget.note.isHidden : ${widget.note.isHidden}');
                widget.notesBloc.add(NotesEnteredEditingEvent(isInHiddenMode: widget.note.isHidden));
                _inEditOnTap();
              },
              onTap: () {
                if (state is! NotesEditingState) {
                  GoRouter.of(context).pushNamed(
                      AppRouteConstants.noteViewRouteName,
                      pathParameters: {'noteId': widget.note.id},
                      extra: widget.notesBloc);
                } else {
                  _inEditOnTap();
                }
              },
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: state is! NotesEditingState
                        ? Row(
                            children: [
                              if (_isSyncing)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SpinKitRing(
                                      color: kPink, lineWidth: 4.0, size: 20),
                                )
                              else ...[
                                if (!widget.note.isUploaded)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.cloud_upload_outlined,
                                      color: kWhite,
                                    ),
                                    onPressed: () {
                                      //add note to cloud
                                      widget.notesBloc.add(
                                          NotesUploadNoteToCloudEvent(
                                              widget.note));
                                    },
                                    tooltip: "upload to cloud",
                                    splashRadius: 15,
                                  ),
                                if (widget.note.isUploaded)
                                  IconButton(
                                    icon: widget.note.isFavorite
                                        ? const Icon(
                                            Icons.star,
                                            color: kPink,
                                          )
                                        : const Icon(Icons.star_border,
                                            color: kWhite),
                                    onPressed: () {
                                      //add to favourites
                                      widget.notesBloc.add(
                                          NotesSetNoteFavoriteEvent(
                                              !widget.note.isFavorite,
                                              widget.note.id));
                                    },
                                    tooltip: 'Favorite note',
                                    splashRadius: 15,
                                  ),
                              ],
                            ],
                          )
                        : Transform.scale(
                            scale: 1.0,
                            child: Checkbox(
                                value: _areAllSelected
                                    ? _areAllSelected
                                    : _isSelected,
                                checkColor: kPink,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                fillColor:
                                    MaterialStateProperty.resolveWith(getColor),
                                onChanged: (_) => _inEditOnTap()),
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
                                style: kInter.copyWith(
                                    color: kWhite, fontSize: 18),
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
                          'created on : ${DateFormat('d MMMM, h:mm a').format(widget.note.createdTime.toLocal()).toString()}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 10),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                        Text(
                          'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.note.editedTime.toLocal()).toString()}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 10),
                        ),
                        Text(
                          'is uploaded : ${widget.note.isUploaded}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 10),
                        ),
                        Text(
                          'is hidden : ${widget.note.isHidden}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 10),
                        ),
                        Text(
                          'is favorite : ${widget.note.isFavorite}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 10),
                        ),
                        if (!_isSyncing) ...[
                          Text(
                            'is synced : ${widget.note.isSynced}',
                            style:
                                kInter.copyWith(color: kWhite75, fontSize: 10),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Text(
                                'syncing',
                                style: kInter.copyWith(
                                    color: kWhite75, fontSize: 10),
                              ),
                              SizedBox(
                                width: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              const SpinKitChasingDots(
                                color: kWhite,
                                size: 15,
                              )
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
