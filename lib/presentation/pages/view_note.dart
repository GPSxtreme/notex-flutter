import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../../core/repositories/notes_repository.dart';
import '../../main.dart';
import '../styles/size_config.dart';

class ViewNotePage extends StatefulWidget {
  const ViewNotePage({super.key, this.noteId, required this.notesBloc});

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
    note.setEditedTime(DateTime.now());
    note.title = _headingController.text;
    setState(() {
      final newValue = _headingController.value;
      _headingHistory.add(newValue);
      _headingHistoryIndex = _headingHistory.length - 1;
    });
  }

  void _onBodyTextChanged() {
    note.setEditedTime(DateTime.now());
    note.body = _bodyController.text;
    setState(() {
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
    if(widget.noteId == null){
      //create new note
      widget.notesBloc.add(NotesAddNoteEvent(note));
      Navigator.of(context).pop();
    }else{
      // update made changes to note.
      note.updateIsSynced(false);
      await NotesRepository.updateNote(note)
          .then((_) {
        widget.notesBloc.add(NotesRefetchNotesEvent(note));
        Navigator.of(context).pop();
      });
    }
  }

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
    return Scaffold(
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
        actions: [
          IconButton(
              splashRadius: 20,
              onPressed: () {
                // perform undo operation
                if (_headingFocusNode.hasPrimaryFocus) {
                  _undoHeading();
                } else {
                  _undoBody();
                }
              },
              icon: const Icon(
                Icons.undo,
                color: kPink,
              )),
          const VerticalDivider(
            color: kWhite75,
            thickness: 1.4,
            indent: 18,
            endIndent: 18,
          ),
          IconButton(
              splashRadius: 20,
              onPressed: () {
                // perform redo operation
                if (_headingFocusNode.hasPrimaryFocus) {
                  _redoHeading();
                } else {
                  _redoBody();
                }
              },
              icon: const Icon(
                Icons.redo,
                color: kPink,
              )),
          SizedBox(
            width: SizeConfig.blockSizeHorizontal! * 5,
          ),
          Padding(
            padding:
                EdgeInsets.only(right: SizeConfig.blockSizeHorizontal! * 5),
            child: IconButton(
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
                  color: kPink,
                )),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kPageBgGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              height: SizeConfig.blockSizeVertical! * 5,
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
    );
  }
}
