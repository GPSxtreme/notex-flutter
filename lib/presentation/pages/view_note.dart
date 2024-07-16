// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:notex/data/models/note_model.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/widgets/common_widgets.dart';
import 'package:notex/presentation/widgets/custom_image_builder.dart';
import 'package:notex/external/simpleMarkdown/markdown_toolbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/repositories/notes_repository.dart';
import '../../main.dart';
import '../styles/size_config.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';

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
      try {
        await NotesRepository.updateNote(note).then((_) {
          widget.notesBloc.add(NotesRefetchNotesEvent(note,
              isInHiddenMode: widget.isInHiddenMode));
          kSnackBar(context, "Saved note");
          Navigator.of(context).pop();
        });
      } catch (e) {
        kSnackBar(
            context, "Error encountered while saving.\nError: ${e.toString()}");
      }
    }
  }

  detailTile(String key, String value) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style:
                  AppText.textBase.copyWith(color: AppColors.mutedForeground),
            ),
            Text(
              value,
              style: AppText.textBaseSemiBold
                  .copyWith(color: AppColors.foreground),
            )
          ],
        ),
      );

  Widget divider() => const Divider(
        thickness: 1.0,
        indent: 20,
        endIndent: 20,
        color: AppColors.border,
      );

  PopupMenuItem<String> _buildPopupMenuItem(
          IconData icon, String title, String value) =>
      PopupMenuItem<String>(
        value: value,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minVerticalPadding: 0,
          horizontalTitleGap: AppSpacing.md,
          minTileHeight: 0,
          leading: Icon(
            icon,
            color: AppColors.mutedForeground,
            size: AppSpacing.iconSizeLg,
          ),
          title: Text(title, style: AppText.textBase),
          tileColor: Colors.transparent,
        ),
      );

  void _showNoteDetails() => showModalBottomSheet(
        showDragHandle: true,
        context: context,
        backgroundColor: AppColors.secondary,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xl, top: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detailTile(
                    'Created on',
                    DateFormat('d MMM yyyy, h:mm a')
                        .format(note.createdTime.toLocal())
                        .toString()),
                divider(),
                detailTile(
                    'Last edited',
                    DateFormat('d MMM yyyy, h:mm a')
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
            ),
          );
        },
      );

  Future<void> shareNoteAsPdfWithHtmlToPdf() async {
    try {
      // Convert Markdown to HTML
      String markdownText = _bodyController.text;
      String htmlText = md.markdownToHtml(markdownText,
          extensionSet: md.ExtensionSet.gitHubWeb);

      String fullHtml = '''
          <!DOCTYPE html>
    <html>
    <head>
      <link href="https://fonts.googleapis.com/css?family=Open+Sans&display=swap" rel="stylesheet">
      <style>
        body {
          margin: 30px !important;
          font-size:24px !important;
          font-family: 'Open Sans', sans-serif !important; /* Ensure Open Sans is used */
        }
        img {
            display: block; /* Allows margin auto to work for horizontal centering */
            max-width: 100%; /* Maximum width of 100% of the parent element */
            max-height: 400px; /* Maximum height of 400 pixels */
            height: auto; /* Maintain aspect ratio */
            margin: auto; /* Center the image horizontally */
          }
      </style>
    </head>
    <body>
      <h1 style="text-align: center; margin-top:30px">${_headingController.text.trim()}</h1>
      <div style="display:flex; flex-direction:row; justify-content:space-between;">
        <div>
          <h4>Created <span style="color:#7377FF;">${DateFormat('d MMMM, h:mm a').format(note.editedTime.toLocal())} </span></h4>
           <h4>By <span style="color:#7377FF;">${USER.data!.name}</span></h4>
        </div>
        <h4>Generated by <span style="color:#7377FF;">Notex</span></h4>
      </div>
      <hr style="margin-bottom: 20px; color:black;">
      $htmlText
    </body>
    </html>
    ''';

      // Convert HTML to PDF
      final tempDir = await getTemporaryDirectory();

      var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
          fullHtml, tempDir.path, note.title);

      // Share the PDF file
      await Share.shareXFiles(<XFile>[XFile(generatedPdfFile.path)],
          text: note.title, subject: 'Sharing Note from Notex');
    } catch (e) {
      kSnackBar(context, "Error generating pdf\nError: $e");
    }
  }

  void _showShareOptions() => showModalBottomSheet(
        showDragHandle: true,
        context: context,
        backgroundColor: AppColors.secondary,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.text_fields,
                      color: AppColors.mutedForeground,
                      size: AppSpacing.iconSizeXl),
                  title: const Text(
                    'Share as text',
                  ),
                  onTap: () async {
                    await Share.share(
                        '${_headingController.text}\n${_bodyController.text}',
                        subject: 'Sharing note from Notex');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.picture_as_pdf,
                      color: AppColors.mutedForeground,
                      size: AppSpacing.iconSizeXl),
                  title: const Text(
                    'Share as pdf',
                  ),
                  onTap: () async {
                    await shareNoteAsPdfWithHtmlToPdf();
                  },
                ),
              ],
            ),
          );
        },
      );
  void _onTapLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Handle the situation when the URL cannot be launched (optional)
      kSnackBar(context, 'Could not launch $url');
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
        body: Center(
          child: SpinKitRing(
            color: AppColors.primary,
            size: AppSpacing.iconSize2Xl,
            lineWidth: 4.0,
          ),
        ),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (_headingHistory.isNotEmpty || _bodyHistory.isNotEmpty) {
          bool? response = await CommonWidgets.commonAlertDialog(context,
              title: 'Exit?',
              body: 'Unsaved changes will be lost.',
              agreeLabel: 'Yes',
              denyLabel: 'No');
          if (response == true) {
            Navigator.of(context).pop();
          }
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leadingWidth: AppSpacing.iconSize2Xl * 2.5,
          leading: Builder(
            builder: (BuildContext context) {
              return Row(
                children: [
                  SizedBox(
                    width: AppSpacing.md,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: AppSpacing.iconSize2Xl,
                    ),
                    onPressed: () async {
                      if (_headingHistory.isNotEmpty ||
                          _bodyHistory.isNotEmpty) {
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
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                ],
              );
            },
          ),
          actions: [
            if (_isInEditing)
              Container(
                margin: EdgeInsets.symmetric(
                    vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: AppBorderRadius.lg),
                child: Row(
                  children: [
                    IconButton(
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
                        )),
                    IconButton(
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
                        )),
                  ],
                ),
              ),
            IconButton(
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
                      )
                    : const Icon(Icons.check)),
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: AppBorderRadius.lg,
                ),
                icon: Icon(
                  Ionicons.ellipsis_vertical,
                  size: AppSpacing.iconSizeXl,
                ),
                color: AppColors.secondary,
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
                      _buildPopupMenuItem(
                          Icons.share_rounded, "Share", 'share'),
                      _buildPopupMenuItem(
                          Icons.info_outline_rounded, "Details", 'details'),
                    ],
                    _buildPopupMenuItem(Icons.save_rounded, "Save", 'save')
                  ];
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Icon(
                      note.isSynced ? Icons.sync : Icons.sync_disabled,
                      size: AppSpacing.iconSizeSm,
                      color: AppColors.mutedForeground,
                    ),
                    SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      DateFormat('d MMMM, h:mm a')
                          .format(note.editedTime.toLocal())
                          .toString(),
                      style: AppText.textSm
                          .copyWith(color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: AppSpacing.sm,
              ),
              TextFormField(
                controller: _headingController,
                onChanged: (_) => _onHeadingTextChanged(),
                focusNode: _headingFocusNode,
                readOnly: !_isInEditing,
                style: AppText.text2XlBlack,
                minLines: 1,
                maxLines: 3,
                decoration: const InputDecoration(
                    hintText: 'Heading', fillColor: AppColors.card),
              ),
              SizedBox(
                height: AppSpacing.sm,
              ),
              if (_isInEditing)
                Flexible(
                  child: Column(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(top: AppSpacing.sm),
                          child: TextFormField(
                            controller: _bodyController,
                            focusNode: _bodyFocusNode,
                            textAlignVertical: TextAlignVertical.top,
                            expands: true,
                            maxLines: null,
                            decoration: const InputDecoration(
                                hintText: 'Content', fillColor: AppColors.card),
                            onChanged: (_) => _onBodyTextChanged(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: AppSpacing.md, bottom: AppSpacing.lg),
                        child: MarkdownToolbar(
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
                        ),
                      )
                    ],
                  ),
                ),
              if (!_isInEditing)
                Flexible(
                  child: MarkdownWidget(
                    shrinkWrap: true,
                    data: _bodyController.text,
                    markdownGenerator: MarkdownGenerator(),
                    config: MarkdownConfig.darkConfig.copy(configs: [
                      PreConfig(
                          theme: atomOneLightTheme,
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: AppBorderRadius.lg)),
                      LinkConfig(
                        onTap: (url) => _onTapLink(url),
                        style: AppText.textBase.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                            color: AppColors
                                .primary), // Styling links with primary color
                      ),
                      ImgConfig(builder: (url, attributes) {
                        return customImageBuilder(url, attributes, context);
                      }),
                      H1Config(
                        style: AppText.text3XlBold, // H1 styling
                      ),
                      H2Config(
                        style: AppText.text2XlBold, // H2 styling
                      ),
                      H3Config(
                        style: AppText.textXlBold, // H3 styling
                      ),
                      H4Config(
                        style: AppText.textLgBold, // H4 styling
                      ),
                      H5Config(
                        style: AppText.textBaseBold, // H5 styling
                      ),
                      H6Config(
                        style: AppText.textSmBold, // H6 styling
                      ),
                      const HrConfig(
                        color: AppColors.border, // Horizontal rule styling
                      ),
                      CheckBoxConfig(
                        builder: (checked) {
                          if (checked) {
                            return Icon(
                              Icons.check_box,
                              color: AppColors.primary,
                              size: AppSpacing.iconSizeLg,
                            );
                          } else {
                            return Icon(
                              Icons.check_box_outline_blank,
                              color: AppColors.primary,
                              size: AppSpacing.iconSizeLg,
                            );
                          }
                        },
                      ),
                      const HrConfig(color: AppColors.border, height: 2.0),
                      const BlockquoteConfig(
                          sideColor: AppColors.primary,
                          textColor: AppColors.foreground)
                    ]),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
