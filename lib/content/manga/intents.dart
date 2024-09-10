import 'package:cloud_hook/content/manga/model.dart';
import 'package:flutter/material.dart';

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class PrevPageIntent extends Intent {
  const PrevPageIntent();
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
  final MangaReaderImageMode mode;
  const SwitchReaderImageMode(this.mode);
}
