import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/content_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/utils/scrapper/scrapper.dart';
import 'package:cloud_hook/utils/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

mixin PlayerJSIframe on ContentDetails {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  PlaylistConvertStrategy<ContentMediaItem> get convertStrategy =>
      DubSeasonEpisodeConvertStrategy();

  String get iframe;

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    _mediaItems ??= await Isolate.run(
      () => PlayerJSExtractor(convertStrategy).extract(iframe),
    );

    return _mediaItems!;
  }
}

mixin DLEChannelsLoader on ContentSupplier {
  String get host;
  Selector<List<Map<String, dynamic>>> get contentInfoSelector;
  Map<String, String> get channelsPath;

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {page = 1}) async {
    final path = channelsPath[channel];

    if (path == null) {
      return const [];
    }

    var tragetPath = path;
    if (path.endsWith("/page/")) {
      tragetPath += page.toString();
    } else if (page > 1) {
      return [];
    }

    final scrapper = Scrapper(uri: Uri.https(host, tragetPath));
    final results = await scrapper.scrap(contentInfoSelector);

    return results.map(ContentSearchResult.fromJson).toList();
  }
}
