import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../blocs/notes/notes_bloc.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with AutomaticKeepAliveClientMixin<NotesPage> {
  @override
  bool get wantKeepAlive => true;
  late NotesBloc notesBloc; // Declare the NotesBloc variable

  @override
  void initState() {
    super.initState();
    notesBloc = BlocProvider.of<NotesBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: notesBloc,
      listenWhen: (previous, current) => current is NotesActionState,
      buildWhen: (previous, current) => current is! NotesActionState,
      listener: (context, state) {},
      builder: (context, state) {
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
                          style: kInter.copyWith(fontSize: 22,fontWeight: FontWeight.w600),
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
                ] else if (state is NotesFetchedState) ...[
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
                          children: [
                            // note widgets go here if present
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: state.notes.length, itemBuilder: (BuildContext context, int notesIndex) {
                                final notes = state.notes;
                                return ListTile(
                                  title: Text(notes[notesIndex].title,style: kInter,),
                                  subtitle: Text(notes[notesIndex].body,style: kInter,),
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
