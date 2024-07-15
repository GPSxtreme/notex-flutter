import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';
import 'package:notex/presentation/widgets/common_widgets.dart';
import 'package:notex/router/app_route_constants.dart';

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
  bool _inHiddenMode = false;
  bool _inDeletedMode = false;

  _inEditOnTap() {
    if (_areAllSelected) {
      widget.notesBloc.add(NotesSetAllNotesSelectedCheckBoxEvent(false,
          isInHiddenMode: widget.note.isHidden));
      _areAllSelected = false;
      if (_areAllSelected && !_isSelected) {
        _isSelected = true;
      } else {
        _isSelected = false;
      }
      widget.notesBloc.add(NotesIsNoteSelectedEvent(_isSelected, widget.note,
          isInHiddenMode: widget.note.isHidden));
    } else {
      _isSelected = !_isSelected;
      widget.notesBloc.add(NotesIsNoteSelectedEvent(_isSelected, widget.note,
          isInHiddenMode: widget.note.isHidden));
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
        if (state is NotesState) {
          _inHiddenMode = state.isInHiddenMode;
          _inDeletedMode = state.isInDeletedMode;
        }
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
            borderRadius: AppBorderRadius.xxl,
            color: AppColors.secondary,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppBorderRadius.xxl,
            child: InkWell(
              borderRadius: AppBorderRadius.xxl,
              onLongPress: !_inDeletedMode
                  ? () {
                      widget.notesBloc.add(NotesEnteredEditingEvent(
                          isInHiddenMode: widget.note.isHidden));
                      _inEditOnTap();
                    }
                  : null,
              onTap: !_inDeletedMode
                  ? () {
                      if (state is! NotesEditingState) {
                        GoRouter.of(context).pushNamed(
                            AppRouteConstants.noteViewRouteName,
                            pathParameters: {
                              'noteId': widget.note.id,
                              'isInHiddenMode': _inHiddenMode.toString()
                            },
                            extra: widget.notesBloc);
                      } else {
                        _inEditOnTap();
                      }
                    }
                  : null,
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
                                      color: AppColors.foreground,
                                      lineWidth: 3.0,
                                      size: 20),
                                )
                              else ...[
                                if (!widget.note.isUploaded &&
                                    !widget.note.isDeleted)
                                  IconButton(
                                    icon: Icon(
                                      Icons.cloud_upload_rounded,
                                      size: AppSpacing.iconSizeXl,
                                    ),
                                    onPressed: () {
                                      //add note to cloud
                                      widget.notesBloc.add(
                                          NotesUploadNoteToCloudEvent(
                                              widget.note));
                                    },
                                    tooltip: "upload to cloud",
                                  ),
                                if (widget.note.isUploaded &&
                                    !widget.note.isDeleted)
                                  IconButton(
                                    icon: widget.note.isFavorite
                                        ? Icon(
                                            Icons.star_rounded,
                                            color: AppColors.primary,
                                            size: AppSpacing.iconSizeXl,
                                          )
                                        : Icon(
                                            Icons.star_border_rounded,
                                            size: AppSpacing.iconSizeXl,
                                          ),
                                    onPressed: () {
                                      //add to favorites
                                      widget.notesBloc.add(
                                          NotesSetNoteFavoriteEvent(
                                              !widget.note.isFavorite,
                                              isInHiddenMode: _inHiddenMode,
                                              widget.note));
                                    },
                                    tooltip: 'Favorite note',
                                  ),
                                if (widget.note.isDeleted)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.restore_from_trash,
                                    ),
                                    onPressed: () async {
                                      //restore note
                                      bool? response =
                                          await CommonWidgets.commonAlertDialog(
                                              context,
                                              title: 'Restore note?',
                                              body:
                                                  'This will restore the deleted note.',
                                              agreeLabel: 'Yes',
                                              denyLabel: "No");
                                      if (response == true) {
                                        widget.notesBloc.add(
                                            NotesRestoreDeletedNoteEvent(
                                                widget.note));
                                      }
                                    },
                                    tooltip: 'restore note',
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                onChanged: (_) => _inEditOnTap()),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: AppSpacing.xl,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              // Add Flexible widget here
                              child: Text(
                                widget.note.title,
                                style: AppText.textLgSemiBold,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSpacing.sm,
                        ),
                        Text(
                          widget.note.body,
                          style: AppText.textSm,
                          maxLines: 7,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        if (!_isSyncing) ...[
                          Row(
                            children: [
                              Icon(
                                  widget.note.isSynced
                                      ? Icons.sync
                                      : Icons.sync_disabled,
                                  color: AppColors.mutedForeground,
                                  size: AppSpacing.iconSizeBase),
                              SizedBox(
                                width: AppSpacing.sm,
                              ),
                              Expanded(
                                child: Text(
                                  DateFormat('h:mm a, dd MMM yyyy')
                                      .format(widget.note.editedTime.toLocal())
                                      .toString(),
                                  style: AppText.textXs.copyWith(
                                      color: AppColors.mutedForeground),
                                ),
                              )
                            ],
                          )
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Syncing...',
                                  style: AppText.textSm.copyWith(
                                      color: AppColors.mutedForeground)),
                              SpinKitChasingDots(
                                color: AppColors.mutedForeground,
                                size: AppSpacing.iconSizeSm,
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
