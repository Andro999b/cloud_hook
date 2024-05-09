String absoluteUrl(String host, String url) {
  final uri = Uri.parse(url);

  return uri.replace(host: host, scheme: "https").toString();
}

final defaultIdRegexp = RegExp(r'https?:\/\/[\w\.\-\d]+\/(?<id>.+).html?');

String extractIdFromUrl(String url, {RegExp? regexp}) {
  final match = (regexp ?? defaultIdRegexp).firstMatch(url);
  final id = match?.namedGroup("id");

  if (id == null) {
    throw Exception("id not found in url: $url");
  }

  return Uri.encodeComponent(id);
}
