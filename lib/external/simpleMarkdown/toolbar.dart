import 'package:flutter/material.dart';

class ToolbarResult {
  final int baseOffset;
  final int extentOffset;
  final String text;

  ToolbarResult({
    required this.baseOffset,
    required this.text,
    required this.extentOffset,
  });
}

class Toolbar {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<bool> isEditorFocused;

  Toolbar(
      {required this.controller,
      required this.focusNode,
      required this.isEditorFocused});

  // check if have selection text
  bool checkHasSelection() {
    return (controller.selection.baseOffset -
            controller.selection.extentOffset) !=
        0;
  }

  // get selection text pffset
  TextSelection getSelection(TextSelection selection) {
    return !selection.isValid
        ? selection.copyWith(
            baseOffset: controller.text.length,
            extentOffset: controller.text.length,
          )
        : selection;
  }

  // toolbar action
  void action(
    String left,
    String right, {
    TextSelection? textSelection,
  }) {
    if (!focusNode.hasFocus) {
      isEditorFocused.call(true);
      focusNode.requestFocus();
    }

    // default parameter
    final currentTextValue = controller.value.text;
    var selection = textSelection ?? controller.selection;
    selection = getSelection(selection);

    final middle = selection.textInside(currentTextValue);
    var selectionText = '$left$middle$right';
    var baseOffset = left.length + middle.length;
    var extentOffset = selection.extentOffset + left.length + right.length;

    // check if middle text have char \n
    if (middle.split("\n").length > 1) {
      ToolbarResult result =
          _multiLineFormating(left, middle, right, selection.extentOffset);
      selectionText = result.text;
      baseOffset = result.baseOffset;
      extentOffset = result.extentOffset;
    }

    // check if middle not have char \n
    if (middle.contains(left) &&
        middle.contains(right) &&
        middle.split("\n").length < 2) {
      selectionText = middle.replaceFirst(left, "").replaceFirst(right, "");
      baseOffset = middle.length - (left.length + right.length);
      extentOffset = selection.extentOffset - (left.length + right.length);
    }

    final newTextValue = selection.textBefore(currentTextValue) +
        selectionText +
        selection.textAfter(currentTextValue);

    // print(selection.extentOffset - (left.length + right.length));

    controller.value = controller.value.copyWith(
      text: newTextValue,
      selection: selection.baseOffset == selection.extentOffset
          ? TextSelection.collapsed(
              offset: selection.baseOffset + baseOffset,
            )
          : TextSelection(
              baseOffset: selection.baseOffset,
              extentOffset: extentOffset,
            ),
    );
  }

  // multiline formating
  ToolbarResult _multiLineFormating(
    String left,
    String middle,
    String right,
    int selection,
  ) {
    final splitData = middle.split("\n");
    var index = 0;
    var resetLength = 0;
    var addLength = 0;

    final selectionText = splitData.map((text) {
      index++;
      addLength += left.length + right.length;

      if (text.contains(left) && text.contains(right)) {
        resetLength += left.length + right.length;

        return index == splitData.length
            ? text.replaceFirst(left, "").replaceFirst(right, "")
            : text.replaceFirst(left, "").replaceFirst(right, "") + "\n";
      }

      if (text.trim().isEmpty) {
        addLength -= left.length + right.length;
      }

      final newText = text.trim().isEmpty ? text : "$left$text$right";
      return index == splitData.length ? newText : "$newText\n";
    }).join();

    final baseOffset = addLength + (middle.length - (resetLength * 2));
    final extentOffset = selection + addLength - (resetLength * 2);

    return ToolbarResult(
      baseOffset: baseOffset,
      text: selectionText,
      extentOffset: extentOffset,
    );
  }

  void selectSingleLine() {
    var currentPosition = controller.selection;
    if (!currentPosition.isValid) {
      currentPosition = currentPosition.copyWith(
        baseOffset: 0,
        extentOffset: 0,
      );
    }
    var textBefore = currentPosition.textBefore(controller.text);
    var textAfter = currentPosition.textAfter(controller.text);

    textBefore = textBefore.split("\n").last;
    textAfter = textAfter.split("\n")[0];
    final firstTextPosition = controller.text.indexOf(textBefore + textAfter);
    controller.value = controller.value.copyWith(
      selection: TextSelection(
        baseOffset: firstTextPosition,
        extentOffset: firstTextPosition + (textBefore + textAfter).length,
      ),
    );
  }
}
