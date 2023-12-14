// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/widgets/common_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_markdown_editor/simple_markdown_editor.dart';
import '../../core/repositories/notes_repository.dart';
import '../../main.dart';
import '../styles/size_config.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class ViewNotePage extends StatefulWidget {
  const ViewNotePage(
      {super.key,
      this.noteId,
      required this.notesBloc,
      this.isInHiddenMode = false});
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
  bool _isInEditing = false;

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
      _isInEditing = true;
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
    if (_headingHistoryIndex == 0 && _bodyHistoryIndex == 0) {
      // no changes
      kSnackBar(context, 'No changes made.');
      Navigator.of(context).pop();
      return;
    }
    if (widget.noteId == null) {
      //create new note
      widget.notesBloc.add(NotesAddNoteEvent(note));
      Navigator.of(context).pop();
    } else {
      // update made changes to note.
      note.updateIsSynced(false);
      kSnackBar(context, "Saving changes...");
      await NotesRepository.updateNote(note).then((_) {
        widget.notesBloc.add(NotesRefetchNotesEvent(note,
            isInHiddenMode: widget.isInHiddenMode));
        kSnackBar(context, "Saved note");
        Navigator.of(context).pop();
      });
    }
  }

  detailTile(String key, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style:
                  kAppFont.copyWith(fontSize: 15, fontWeight: FontWeight.w400),
            ),
            Text(
              value,
              style:
                  kAppFont.copyWith(fontSize: 15, fontWeight: FontWeight.w400),
            )
          ],
        ),
      );

  divider() => Divider(
        color: kPinkD1.withOpacity(0.3),
        thickness: 1.0,
        indent: 20,
        endIndent: 20,
      );

  void _showNoteDetails() => showModalBottomSheet(
        showDragHandle: true,
        backgroundColor: kPinkD2,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              detailTile(
                  'Created on',
                  DateFormat('d MMMM, h:mm a')
                      .format(note.createdTime.toLocal())
                      .toString()),
              divider(),
              detailTile(
                  'Last edited',
                  DateFormat('d MMMM, h:mm a')
                      .format(note.editedTime.toLocal())
                      .toString()),
              divider(),
              detailTile('Changes made', note.v.toString()),
              divider(),
              detailTile('Is synced', note.isSynced ? 'yes' : 'no'),
              divider(),
              detailTile('Is uploaded', note.isUploaded ? 'yes' : 'no'),
              divider(),
              detailTile('Is favorite', note.isFavorite ? 'yes' : 'no'),
              divider(),
              detailTile('Is hidden', note.isHidden ? 'yes' : 'no')
            ],
          );
        },
      );

  Future<void> shareNoteAsPdf() async {
    // Generate PDF file from note content
    final pdf = pw.Document();
    final text = _bodyController.text.trim();
    final List<String> lines = text
        .split('\n'); // Split text into paragraphs using '\n' as the delimiter

    pdf.addPage(
      pw.MultiPage(
        maxPages: 1000,
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  _headingController.text.trim(),
                  style: const pw.TextStyle(fontSize: 25),
                ),
              ),
              pw.SizedBox(height: 25),
              pw.Row(children: [
                pw.Text(
                  'Notex',
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.Spacer(),
                pw.Text(
                  DateFormat('d MMMM, h:mm a')
                      .format(note.editedTime.toLocal())
                      .toString(),
                  style: const pw.TextStyle(fontSize: 15),
                ),
              ]),
              pw.SizedBox(height: 5),
              pw.Divider(thickness: 2.0, color: PdfColors.pink, height: 0),
              pw.SizedBox(height: 25),
              for (var line in lines)
                pw.Text(line.trim(),
                    style: const pw.TextStyle(fontSize: 17),
                    textAlign: pw.TextAlign.left)
            ],
          ),
        ],
      ),
    );
    // Save the PDF file to a temporary directory
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/note.pdf';
    final file = File(tempPath);
    await file.writeAsBytes(await pdf.save());

    // Share the PDF file
    await Share.shareXFiles(<XFile>[XFile(tempPath)],
        text: 'My Note', subject: 'Sharing Note from Notex');
  }

  void _showShareOptions() => showModalBottomSheet(
        backgroundColor: kPinkD2,
        showDragHandle: true,
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.text_fields,
                  color: kWhite,
                ),
                title: Text(
                  'Share as text',
                  style: kAppFont,
                ),
                onTap: () async {
                  await Share.shareWithResult(
                      '${_headingController.text}\n${_bodyController.text}',
                      subject: 'Sharing note from notex.');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: kWhite,
                ),
                title: Text(
                  'Share as pdf',
                  style: kAppFont,
                ),
                onTap: () async {
                  await shareNoteAsPdf();
                },
              ),
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
      onWillPop: () async {
        if (_headingHistory.isNotEmpty || _bodyHistory.isNotEmpty) {
          bool? response = await CommonWidgets.commonAlertDialog(context,
              title: 'Exit?',
              body: 'Unsaved changes will be lost.',
              agreeLabel: 'Yes',
              denyLabel: 'No');
          return response ?? false;
        } else {
          return true;
        }
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
                onPressed: () async {
                  if (_headingHistory.isNotEmpty || _bodyHistory.isNotEmpty) {
                    bool? response = await CommonWidgets.commonAlertDialog(
                        context,
                        title: 'Exit?',
                        body: 'Unsaved changes will be lost.',
                        agreeLabel: 'Yes',
                        denyLabel: 'No');
                    if (response == true) {
                      GoRouter.of(context).pop();
                    }
                  } else {
                    GoRouter.of(context).pop();
                  }
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              );
            },
          ),
          actions: [
            if (_isInEditing)
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: SizeConfig.blockSizeHorizontal! * 2),
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                // decoration: BoxDecoration(
                //     color: kPinkD1, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    SizedBox(width: SizeConfig.blockSizeHorizontal! * 2),
                    IconButton(
                        splashRadius: 20,
                        tooltip: 'perform undo action',
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
                          color: kWhite,
                        )),
                    IconButton(
                        splashRadius: 20,
                        tooltip: 'perform redo action',
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
                          color: kWhite,
                        )),
                  ],
                ),
              ),
            IconButton(
                splashRadius: 20,
                tooltip: 'edit note',
                onPressed: () {
                  setState(() {
                    _bodyFocusNode.requestFocus();
                    _isInEditing = !_isInEditing;
                  });
                },
                icon: !_isInEditing
                    ? const Icon(
                        Icons.edit,
                        color: kWhite,
                      )
                    : const Icon(Icons.check, color: kWhite)),
            Padding(
              padding:
                  EdgeInsets.only(right: SizeConfig.blockSizeHorizontal! * 5),
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
                onSelected: (value) async {
                  switch (value) {
                    case 'share':
                      _showShareOptions();
                    case 'details':
                      _showNoteDetails();
                      break;
                    case 'save':
                      _saveChanges();
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    if (_headingController.text.isNotEmpty &&
                        _bodyController.text.isNotEmpty) ...[
                      PopupMenuItem<String>(
                        value: 'share',
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          horizontalTitleGap: 15,
                          leading: const Icon(
                            Icons.share,
                            color: kPinkD1,
                          ),
                          title: Text(
                            'share',
                            style: kAppFont.copyWith(fontSize: 13),
                          ),
                          tileColor: Colors.transparent,
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'details',
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 0),
                          horizontalTitleGap: 15,
                          leading: const Icon(
                            Icons.details_outlined,
                            color: kPinkD1,
                          ),
                          title: Text(
                            'details',
                            style: kAppFont.copyWith(fontSize: 13),
                          ),
                          tileColor: Colors.transparent,
                        ),
                      ),
                    ],
                    PopupMenuItem<String>(
                      value: 'save',
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        horizontalTitleGap: 15,
                        leading: const Icon(
                          Icons.save,
                          color: kPinkD1,
                        ),
                        title: Text(
                          'save',
                          style: kAppFont.copyWith(fontSize: 13),
                        ),
                        tileColor: Colors.transparent,
                      ),
                    )
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
                    note.isSynced == true
                        ? const Icon(
                            Icons.sync,
                            color: kWhite,
                            size: 12,
                          )
                        : const Icon(
                            Icons.sync_disabled,
                            color: kWhite,
                            size: 12,
                          ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      DateFormat('d MMMM, h:mm a')
                          .format(note.editedTime.toLocal())
                          .toString(),
                      style: kAppFont.copyWith(color: kWhite75, fontSize: 10),
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
                readOnly: !_isInEditing,
                minLines: 1,
                maxLines: 3,
                style: kAppFont.copyWith(fontSize: 30),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 25),
                  hintText: 'Heading',
                  hintStyle: kAppFont.copyWith(
                      color: kWhite.withOpacity(0.2),
                      fontSize: 30,
                      fontWeight: FontWeight.w300),
                ),
              ),
              SizedBox(
                height: SizeConfig.blockSizeVertical! * 3,
              ),
              if (_isInEditing)
                Flexible(
                  child: Column(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _bodyController,
                          focusNode: _bodyFocusNode,
                          expands: true,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 25),
                            hintText: 'Content',
                            hintStyle: kAppFont.copyWith(
                                color: kWhite.withOpacity(0.2),
                                fontSize:  16,
                                fontWeight: FontWeight.w300),
                          ),
                          onChanged: (_) => _onBodyTextChanged(),
                          style: kAppFont.copyWith(fontSize: 16),
                          cursorColor: kWhite,
                        ),
                      ),
                      MarkdownToolbar(
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        onPreviewChanged: () {
                          setState(() {
                            _isInEditing = !_isInEditing;
                          });
                        },
                        isEditorFocused: (bool value) {
                          setState(() {
                            _isInEditing = value;
                          });
                        },
                      )
                    ],
                  ),
                ),
              if (!_isInEditing)
                Flexible(
                  child: MarkdownWidget(
                    loadingWidget: const SpinKitCircle(color: kWhite,),
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 30, left: 25, right: 25),
                    data: _bodyController.text,
                    styleConfig: StyleConfig(
                      markdownTheme: MarkdownTheme.darkTheme,
                      // pConfig: PConfig(
                      //   textStyle: kAppFont.copyWith(fontSize: 20),
                      //   linkStyle: const TextStyle(color: Colors.blue),
                      // ),
                      // Add more styling as per your need
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
