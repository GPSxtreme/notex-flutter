import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notex/data/models/note_model.dart';
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
      buildWhen: (previous, current) => current is! NotesActionState,
      listener: (context, state) {
        if (state is NotesOperationFailedState) {
          kSnackBar(context, state.reason);
        }
      },
      builder: (context, state) {
        if (state is NotesFetchedState) {
          _notes = state.notes;
          if (state.syncingNotes != null) {
            _isSyncing = true;
            _noOfNotesSyncing = state.syncingNotes!.length;
          } else {
            _isSyncing = false;
          }
        } else if (state is NotesEditingState) {
          _notes = state.notes;
        }
        int numberOfColumns = SizeConfig.screenWidth! > 600 ? 3 : 2;
        return Scaffold(
          appBar: null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            decoration: const BoxDecoration(gradient: kPageBgGradient),
            child: Stack(
              children: [
                if (state is NotesEmptyState) ...[
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: SizeConfig.screenWidth! * 0.1,
                    right: SizeConfig.screenWidth! * 0.1,
                    child: SvgPicture.asset(
                      "assets/svg/magnify-glass.svg",
                    ),
                  ),
                  // showed when no notes are found
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: SizeConfig.screenWidth! * 0.1,
                      right: SizeConfig.screenWidth! * 0.1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'No',
                                style: kInter.copyWith(
                                    fontSize: 30, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: SizeConfig.blockSizeHorizontal! * 2,
                              ),
                              Text(
                                ' notes',
                                style: kInter.copyWith(
                                  color: kPink,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Found',
                            style: kInter.copyWith(
                                fontSize: 30, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: SizeConfig.blockSizeVertical! * 3,
                          ),
                          Text(
                            "You can add new note by pressing\nAdd button at the bottom",
                            style:
                                kInter.copyWith(fontSize: 15, color: kWhite24),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )),
                ] else if (state is NotesFetchingState) ...[
                  const Center(
                    child: SpinKitRing(
                      color: kPinkD1,
                      size: 35,
                    ),
                  )
                ] else if (state is NotesFetchingFailedState) ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load notes',
                          style: kInter.copyWith(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 2,
                        ),
                        Text(
                          state.reason,
                          style: kInter.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                ] else if (state is NotesFetchedState ||
                    state is NotesEditingState) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isSyncing) ...[
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 375),
                                child: FlipAnimation(
                                  child: FadeInAnimation(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: kPinkD2,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: kPinkD1, width: 1.0)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$_noOfNotesSyncing ${_noOfNotesSyncing == 1 ? 'note is' : "notes are"} syncing',
                                                  style: kInter.copyWith(
                                                      fontSize: 15),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Please do not quit',
                                                  style: kInter.copyWith(
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SpinKitRing(
                                            color: kWhite,
                                            lineWidth: 3.0,
                                            size: 20,
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
                                    final selectedNotes = snapshot.data;
                                    if (selectedNotes != null) {
                                      final selectedNotesCount =
                                          selectedNotes.length;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Text(
                                          'Selected (${selectedNotesCount.toString()})',
                                          style: kInter.copyWith(
                                              fontSize: 35,
                                              fontWeight: FontWeight.w500),
                                        ),
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
                            SizedBox(
                              height: !_isSyncing ||
                                      !notesBloc.isSelectedNotesStreamClosed
                                  ? SizeConfig.blockSizeVertical! * 3
                                  : SizeConfig.blockSizeVertical! * 2,
                            ),
                            MasonryGridView.count(
                              crossAxisCount: numberOfColumns,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _notes.length,
                              itemBuilder:
                                  (BuildContext context, int notesIndex) {
                                final notes = _notes;
                                final note = notes[notesIndex];
                                // not being used as staggeredTileBuilder is not provided for this widget
                                bool isLongText = isTextLong(note.title, 18);
                                return AnimationConfiguration.staggeredGrid(
                                  position: notesIndex,
                                  duration: const Duration(milliseconds: ANIMATION_DURATION),
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
