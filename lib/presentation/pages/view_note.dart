// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/widgets/common_widgets.dart';
import '../../core/repositories/notes_repository.dart';
import '../../main.dart';
import '../styles/size_config.dart';

class ViewNotePage extends StatefulWidget {
  const ViewNotePage({super.key, this.noteId, required this.notesBloc,this.isInHiddenMode = false});
  final bool isInHiddenMode;
  final String? noteId;
  final NotesBloc notesBloc;

  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  bool _isLoading = true;
  late NoteModel note;
  late FocusNode _headingFocusNode;
  late FocusNode _bodyFocusNode;
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final List<TextEditingValue> _headingHistory = [];
  final List<TextEditingValue> _bodyHistory = [];
  int _headingHistoryIndex = 0;
  int _bodyHistoryIndex = 0;

  fetchNote() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.noteId != null) {
      note = await LOCAL_DB.getNote(widget.noteId!);
      _headingController.text = note.title;
      _bodyController.text = note.body;
    } else {
      // create new note
      note = NoteModel.createEmptyNote();
    }
    _headingFocusNode = FocusNode();
    _bodyFocusNode = FocusNode();
    setState(() {
      _isLoading = false;
    });
  }

  void _onHeadingTextChanged() {
    note.title = _headingController.text;
    setState(() {
      note.setEditedTime(DateTime.now());
      note.updateIsSynced(false);
      final newValue = _headingController.value;
      _headingHistory.add(newValue);
      _headingHistoryIndex = _headingHistory.length - 1;
    });
  }

  void _onBodyTextChanged() {
    note.body = _bodyController.text;
    setState(() {
      note.setEditedTime(DateTime.now());
      note.updateIsSynced(false);
      final newValue = _bodyController.value;
      _bodyHistory.add(newValue);
      _bodyHistoryIndex = _bodyHistory.length - 1;
    });
  }

  void _undoHeading() {
    if (_headingHistoryIndex > 0) {
      setState(() {
        _headingHistoryIndex--;
        _headingController.value = _headingHistory[_headingHistoryIndex];
      });
    }
  }

  void _redoHeading() {
    if (_headingHistoryIndex < _headingHistory.length - 1) {
      setState(() {
        _headingHistoryIndex++;
        _headingController.value = _headingHistory[_headingHistoryIndex];
      });
    }
  }

  void _undoBody() {
    if (_bodyHistoryIndex > 0) {
      setState(() {
        _bodyHistoryIndex--;
        _bodyController.value = _bodyHistory[_bodyHistoryIndex];
      });
    }
  }

  void _redoBody() {
    if (_bodyHistoryIndex < _bodyHistory.length - 1) {
      setState(() {
        _bodyHistoryIndex++;
        _bodyController.value = _bodyHistory[_bodyHistoryIndex];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNote();
  }

  Future<void> _saveChanges() async {
    if( _headingHistoryIndex == 0 && _bodyHistoryIndex == 0){
      Navigator.of(context).pop();
      return;
    }
    if(widget.noteId == null){
      //create new note
      widget.notesBloc.add(NotesAddNoteEvent(note));
      Navigator.of(context).pop();
    }else{
      // update made changes to note.
      note.updateIsSynced(false);
      await NotesRepository.updateNote(note)
          .then((_) {
        widget.notesBloc.add(NotesRefetchNotesEvent(note,isInHiddenMode: widget.isInHiddenMode));
        Navigator.of(context).pop();
      });
    }
  }

  detailTile(String key,String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,style: kInter.copyWith(fontSize: 15,fontWeight: FontWeight.w400),
        ),
        Text(
          value,style: kInter.copyWith(fontSize: 15,fontWeight: FontWeight.w400),
        )
      ],
    ),
  );

  void _showNoteDetails() => showModalBottomSheet(
    showDragHandle: true,
    backgroundColor: kPinkD2,
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          detailTile('Created on', DateFormat('d MMMM, h:mm a').format(note.createdTime.toLocal()).toString()),
          detailTile('Last edited', DateFormat('d MMMM, h:mm a').format(note.editedTime.toLocal()).toString()),
          detailTile('Is synced', note.isSynced ? 'yes' : 'no'),
          detailTile('Is uploaded', note.isUploaded ? 'yes' : 'no'),
          detailTile('Is favorite', note.isFavorite ? 'yes' : 'no'),
          detailTile('Is hidden', note.isHidden ? 'yes' : 'no')
        ],
      );
    },
  );

  @override
  void dispose() {
    _headingController.dispose();
    _bodyController.dispose();
    _headingFocusNode.dispose();
    _bodyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: kPageBgGradient,
          ),
          child: const Center(
            child: SpinKitRing(
              color: kWhite,
              size: 35,
            ),
          ),
        ),
      );
    }
    return WillPopScope(
      onWillPop: () async{
          bool? response = await CommonWidgets.commonAlertDialog(context, title: 'Exit?', body: 'Unsaved changes will be lost.', agreeLabel: 'Yes', denyLabel: 'No');
          return response ?? false;
      },
      child: Scaffold(
        backgroundColor: kPageBgStart,
        appBar: AppBar(
          backgroundColor: kPageBgStart,
          elevation: 0,
          leadingWidth: SizeConfig.blockSizeHorizontal! * 25,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                splashRadius: 20,
                icon: const Icon(Icons.arrow_back),
                onPressed: () async{
                  bool? response = await CommonWidgets.commonAlertDialog(context, title: 'Exit?', body: 'Unsaved changes will be lost.', agreeLabel: 'Yes', denyLabel: 'No');
                  if(response == true) {
                    GoRouter.of(context).pop();
                  }
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              );
            },
          ),
          actions: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 9,horizontal: SizeConfig.blockSizeHorizontal! * 2),
              padding:const EdgeInsets.symmetric(vertical: 0,horizontal: 10) ,
              decoration: BoxDecoration(
                color: kPinkD1,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Row(
                children: [
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                  GestureDetector(
                      onTap: () {
                        // perform undo operation
                        if (_headingFocusNode.hasPrimaryFocus) {
                          _undoHeading();
                        } else {
                          _undoBody();
                        }
                      },
                      child: const Icon(
                        Icons.undo,
                        color: kWhite,
                      )),
                  SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                  GestureDetector(
                      onTap: () {
                        // perform redo operation
                        if (_headingFocusNode.hasPrimaryFocus) {
                          _redoHeading();
                        } else {
                          _redoBody();
                        }
                      },
                      child: const Icon(
                        Icons.redo,
                        color: kWhite,
                      )),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal! * 5,
                  ),
                  IconButton(
                      splashRadius: 20,
                      onPressed: () async {
                        // perform save operation
                        if(_headingController.text.isNotEmpty && _bodyController.text.isNotEmpty) {
                          await _saveChanges();
                        } else{
                          kSnackBar(context, "Please fill in heading and body");
                        }
                      },
                      icon: const Icon(
                        Icons.check,
                        color: kWhite,
                      )),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: SizeConfig.blockSizeHorizontal! * 5),
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: kPinkD2,
                icon: const Icon(
                  Ionicons.ellipsis_vertical,
                  color: kWhite,
                ),
                splashRadius: 20,
                onSelected: (value) {
                  switch (value) {
                    case 'details':
                      _showNoteDetails();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'share',
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 0),
                        horizontalTitleGap: 15,
                        leading: const Icon(
                          Icons.share,
                          color: kPinkD1,
                        ),
                        title: Text(
                          'share',
                          style: kInter.copyWith(fontSize: 13),
                        ),
                        tileColor: Colors.transparent,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'details',
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(
                            vertical: 0),
                        horizontalTitleGap: 15,
                        leading: const Icon(
                          Icons.details_outlined,
                          color: kPinkD1,
                        ),
                        title: Text(
                          'details',
                          style: kInter.copyWith(fontSize: 13),
                        ),
                        tileColor: Colors.transparent,
                      ),
                    ),
                  ];
                },
              ),
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: kPageBgGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    note.isSynced == true ? const Icon(Icons.sync,color: kWhite,size: 12,) : const Icon(Icons.sync_disabled,color: kWhite,size: 12,),
                    const SizedBox(width: 5,),
                    Text(
                      DateFormat('d MMMM, h:mm a').format(note.editedTime.toLocal()).toString(),
                      style: kInter.copyWith(color: kWhite75, fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical!,
              ),
              TextFormField(
                controller: _headingController,
                cursorColor: kWhite,
                onChanged: (_) => _onHeadingTextChanged(),
                focusNode: _headingFocusNode,
                minLines: 1,
                maxLines: 3,
                style: kInter.copyWith(fontSize: 30),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  hintText: 'Heading',
                  hintStyle: kInter.copyWith(
                      color: kWhite.withOpacity(0.2),
                      fontSize: 30,
                      fontWeight: FontWeight.w300),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 3,
              ),
              Flexible(
                child: TextFormField(
                  controller: _bodyController,
                  expands: true,
                  focusNode: _bodyFocusNode,
                  onChanged: (_) => _onBodyTextChanged(),
                  style: kInter.copyWith(fontSize: 20),
                  cursorColor: kWhite,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                    hintText: 'Content',
                    hintStyle: kInter.copyWith(
                        color: kWhite.withOpacity(0.2),
                        fontSize: 20,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
