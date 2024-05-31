import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/media_extrators/extractor.dart';
import 'package:cloud_hook/content_suppliers/media_extrators/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:json_annotation/json_annotation.dart';

mixin PLayerJSIframe {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  MediaExtractor get mediaExtractor =>
      PlayerJSExtractor(DubSeasonEpisodeConvertStrategy());
}

mixin AsyncIframe on ContentDetails {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  MediaExtractor get mediaExtractor;

  String get iframe;

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    _mediaItems ??= await Isolate.run(
      () => mediaExtractor.extract(iframe),
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
