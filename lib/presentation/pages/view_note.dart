import 'package:flutter/material.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../../main.dart';
import '../styles/size_config.dart';


class ViewNotePage extends StatefulWidget {
  const ViewNotePage({super.key, required this.noteId});
  final String noteId;
  @override
  State<ViewNotePage> createState() => _ViewNotePageState();
}

class _ViewNotePageState extends State<ViewNotePage> {
  late NoteModel fetchedNote;


  fetchNote() async{
    fetchedNote = await LOCAL_DB.getNote(widget.noteId);
    print(fetchedNote.toJson());
  }

  @override
  void initState() {
    super.initState();
    fetchNote();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
              onPressed: () { Navigator.of(context).pop(); },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: kPageBgGradient
        ),
      ),
    );
  }
}
