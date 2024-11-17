import 'package:strumok/content/manga/model.dart';
import 'package:flutter/material.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class PrevPageIntent extends Intent {
  const PrevPageIntent();
}

class NextChapterIntent extends Intent {
  const NextChapterIntent();
}

class PrevChapterIntent extends Intent {
  const PrevChapterIntent();
}

class ScrollDownPageIntent extends Intent {
  const ScrollDownPageIntent();
}

class ScrollUpPageIntent extends Intent {
  const ScrollUpPageIntent();
}

class ShowUIIntent extends Intent {
  const ShowUIIntent();
}

class SwitchReaderImageMode extends Intent {
  final MangaReaderScale mode;
  const SwitchReaderImageMode(this.mode);
}
