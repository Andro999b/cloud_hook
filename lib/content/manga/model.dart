enum MangaReaderScale {
  fit,
  fitHeight,
  fitWidth,
}

enum MangaReaderMode {
  vertical(false),
  leftToRight(false),
  rightToLeft(false),
  vericalScroll(true),
  hotizontalScroll(true);

  final bool scroll;

  const MangaReaderMode(this.scroll);
}

enum MangaReaderBackground {
  light,
  dark,
}
