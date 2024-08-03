import 'dart:math';

int _hunterDef(String d, int e, int f) {
  const charset =
      "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
  final sourceBase = charset.substring(0, e).codeUnits;
  final targetBase = charset.substring(0, f);

  final reversed = d.codeUnits.reversed.toList();

  int result = 0;

  for (int i = 0; i < reversed.length; i++) {
    int code = reversed[i];

    int sourceBaseIndex = sourceBase.indexOf(code);
    if (sourceBaseIndex != -1) {
      result += sourceBaseIndex * pow(e, i).toInt();
    }
  }

  var convertedResult = "";
  while (result > 0) {
    final index = result % f;
    convertedResult = targetBase[index] + convertedResult;
    result = ((result - index) / f).floor();
  }

  return int.parse(convertedResult);
}

String hunterUnpack(
  String h,
  String u,
  String n,
  int t,
  int e,
  int r,
) {
  int i = 0;
  final result = StringBuffer();

  while (i < h.length) {
    int j = 0;
    var s = "";

    while (h.codeUnitAt(i) != n.codeUnitAt(e)) {
      s += h[i];
      i++;
    }

    while (j < n.length) {
      s = s.replaceAll(n[j], j.toString());
      j++;
    }

    result.writeCharCode((_hunterDef(s, e, 10) - t));

    i++;
  }

  return result.toString();
}
