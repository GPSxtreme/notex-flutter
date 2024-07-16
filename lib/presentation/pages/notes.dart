import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/widgets/note_tile.dart';
import '../blocs/notes/notes_bloc.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

// ignore: constant_identifier_names
const ANIMATION_DURATION = 375;

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>
    with
        AutomaticKeepAliveClientMixin<NotesPage>,
        SingleTickerProviderStateMixin {
  late NotesBloc notesBloc; // Declare the todosBloc variable
  late List<NoteModel> _notes;
  bool _isSyncing = false;
  int _noOfNotesSyncing = 0;
  bool _isHiddenMode = false;
  bool _isDeletedMode = false;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    notesBloc = BlocProvider.of<NotesBloc>(context);
  }

  int calculateMaxWordsPerLine(double fontSize) {
    final screenWidth = SizeConfig.screenWidth!;
    final avgWordWidth = 4.5 * (SizeConfig.blockSizeHorizontal! + fontSize);
    return (screenWidth ~/ avgWordWidth) ~/ 1.3;
  }

  bool isTextLong(String text, double fontSize) {
    int maxWordsPerLine = calculateMaxWordsPerLine(fontSize);
    List<String> words = text.split(' ');
    return words.length >= 2.5 * maxWordsPerLine;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);

    return BlocConsumer(
      bloc: notesBloc,
      listenWhen: (previous, current) => current is NotesActionState,
      buildWhen: (previous, current) =>
          current is! NotesActionState || current is NotesEditingState,
      listener: (context, state) {
        if (state is NotesOperationFailedState) {
          kSnackBar(context, state.reason);
        }
      },
      builder: (context, state) {
        if (state is NotesState) {
          _isHiddenMode = state.isInHiddenMode;
          _isDeletedMode = state.isInDeletedMode;
        }
        if (state is NotesFetchedState) {
          _notes = state.notes;
          // sort notes by date updated and all favorite notes at the top
          _notes.sort((a, b) {
            if (a.isFavorite && !b.isFavorite) {
              return -1;
            } else if (!a.isFavorite && b.isFavorite) {
              return 1;
            } else {
              return b.editedTime.compareTo(a.editedTime);
            }
          });
          if (state.syncingNotes != null) {
            _isSyncing = true;
            _noOfNotesSyncing = state.syncingNotes!.length;
          } else {
            _isSyncing = false;
          }
        }
        if (state is NotesEditingState) {
          _notes = state.notes.where((n) => n.isDeleted == false).toList();
        }
        int numberOfColumns =
            (SizeConfig.screenWidth! / 300).ceil().clamp(1, 4);
        return Scaffold(
          body: Container(
            margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Stack(
              children: [
                if (state is NotesEmptyState) ...[
                  // showed when no notes are found
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: AppColors.muted,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Icon(
                              _isHiddenMode
                                  ? Icons.visibility_off_rounded
                                  : _isDeletedMode
                                      ? Icons.delete_rounded
                                      : Icons.note_add_rounded,
                              color: AppColors.mutedForeground,
                              size: AppSpacing.iconSize2Xl,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Text(
                          'No Notes',
                          style: AppText.textXlBold,
                        ),
                        Text(
                          _isHiddenMode
                              ? 'Hidden'
                              : _isDeletedMode
                                  ? 'Deleted'
                                  : 'Found',
                          style: AppText.textBaseBold,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.6,
                          child: Text(
                            _isHiddenMode
                                ? "You can hide a note by long pressing and selecting hide option from the bottom action bar"
                                : _isDeletedMode
                                    ? "All deleted notes are retained for 30 days and can be restored."
                                    : "You can add new note by pressing\nAdd button at the bottom",
                            textAlign: TextAlign.center,
                            style: AppText.textSm
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        )
                      ],
                    ),
                  ),
                ] else if (state is NotesFetchingState) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitRing(
                        color: AppColors.primary,
                        size: AppSpacing.iconSize3Xl,
                        lineWidth: 5,
                      ),
                      SizedBox(
                        height: AppSpacing.lg,
                      ),
                      Text('This might take a while',
                          textAlign: TextAlign.center,
                          style: AppText.textSm
                              .copyWith(color: AppColors.mutedForeground))
                    ],
                  )
                ] else if (state is NotesFetchingFailedState) ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: AppColors.muted,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Icon(
                              _isHiddenMode
                                  ? Icons.visibility_off_rounded
                                  : _isDeletedMode
                                      ? Icons.delete_rounded
                                      : Icons.note_add_rounded,
                              color: AppColors.mutedForeground,
                              size: AppSpacing.iconSize2Xl,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Text(
                          'Failed to load notes',
                          style: AppText.textXlBold,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        Text(
                          state.reason,
                          textAlign: TextAlign.center,
                          style: AppText.textSm
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  )
                ] else if (state is NotesFetchedState ||
                    state is NotesEditingState) ...[
                  NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overScroll) {
                      overScroll.disallowIndicator();
                      return true;
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isSyncing) ...[
                            AnimationConfiguration.synchronized(
                              duration: const Duration(milliseconds: 375),
                              child: FlipAnimation(
                                child: FadeInAnimation(
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: AppSpacing.md),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.md),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      borderRadius: AppBorderRadius.lg,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$_noOfNotesSyncing ${_noOfNotesSyncing == 1 ? 'note is' : "notes are"} syncing',
                                                style: AppText.textBase,
                                              ),
                                              SizedBox(
                                                height: AppSpacing.sm,
                                              ),
                                              Text(
                                                'PLEASE DO NOT QUIT',
                                                style: AppText.textSmBold
                                                    .copyWith(
                                                        color: AppColors
                                                            .mutedForeground),
                                              )
                                            ],
                                          ),
                                        ),
                                        SpinKitRing(
                                          color: AppColors.primary,
                                          lineWidth: 3.0,
                                          size: AppSpacing.iconSizeXl,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                          if (!notesBloc.isSelectedNotesStreamClosed)
                            StreamBuilder<List<NoteModel>>(
                              stream: notesBloc.selectedNotesStream,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data != null) {
                                    final selectedNotes = snapshot.data!;
                                    final selectedNotesCount =
                                        selectedNotes.length;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: AppSpacing.lg,
                                          top: AppSpacing.md),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Selected ',
                                            style: AppText.textBaseMedium
                                                .copyWith(
                                                    color:
                                                        AppColors.foreground)),
                                        TextSpan(
                                            text: '$selectedNotesCount ',
                                            style: AppText.textLgBold.copyWith(
                                                color: AppColors.primary)),
                                      ])),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else {
                                  // Handle the case when the snapshot doesn't have data yet
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          if (_isHiddenMode &&
                              state is! NotesEditingState &&
                              !_isSyncing) ...[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: AppBorderRadius.full),
                              child: Center(
                                child: RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: 'Hidden ',
                                      style: AppText.textBaseMedium.copyWith(
                                          color: AppColors.foreground)),
                                  TextSpan(
                                      text: '${_notes.length}',
                                      style: AppText.textLgBold
                                          .copyWith(color: AppColors.primary)),
                                ])),
                              ),
                            ),
                            SizedBox(
                              height: AppSpacing.md,
                            ),
                          ] else if (_isDeletedMode &&
                              state is! NotesEditingState &&
                              !_isSyncing) ...[
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              decoration: BoxDecoration(
                                  color: AppColors.muted,
                                  borderRadius: AppBorderRadius.full),
                              child: Column(
                                children: [
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Deleted ',
                                        style: AppText.textBaseMedium.copyWith(
                                            color: AppColors.foreground)),
                                    TextSpan(
                                        text: '${_notes.length}',
                                        style: AppText.textLgBold.copyWith(
                                            color: AppColors.primary)),
                                  ])),
                                  SizedBox(
                                    height: AppSpacing.sm,
                                  ),
                                  Text(
                                    '(Deleted notes are retained for 30 days)',
                                    style: AppText.textSm.copyWith(
                                        color: AppColors.mutedForeground),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: AppSpacing.md,
                            ),
                          ],
                          MasonryGridView.count(
                            crossAxisCount: numberOfColumns,
                            mainAxisSpacing: AppSpacing.md,
                            crossAxisSpacing: AppSpacing.md,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _notes.length,
                            itemBuilder:
                                (BuildContext context, int notesIndex) {
                              final notes = _notes;
                              final note = notes[notesIndex];
                              // not being used as staggeredTileBuilder is not provided for this widget
                              bool isLongText = isTextLong(
                                  note.title, 16 * SizeConfig.textScaleFactor!);
                              return AnimationConfiguration.staggeredGrid(
                                position: notesIndex,
                                duration: const Duration(
                                    milliseconds: ANIMATION_DURATION),
                                columnCount: isLongText ? 1 : numberOfColumns,
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: NoteTile(
                                      note: note,
                                      notesBloc: notesBloc,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}
