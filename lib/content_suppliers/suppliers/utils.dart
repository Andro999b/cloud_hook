import 'dart:isolate';

import 'package:cloud_hook/content_suppliers/extrators/playerjs/playerjs.dart';
import 'package:cloud_hook/content_suppliers/model.dart';
import 'package:cloud_hook/content_suppliers/scrapper/scrapper.dart';
import 'package:cloud_hook/content_suppliers/scrapper/selectors.dart';
import 'package:cloud_hook/utils/logger.dart';
import 'package:json_annotation/json_annotation.dart';

mixin PLayerJSIframe {
  String get iframe;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  ContentMediaItemLoader get mediaExtractor => PlayerJSExtractor(iframe, DubSeasonEpisodeConvertStrategy());
}

mixin AsyncMediaItems on ContentDetails {
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  ContentMediaItemLoader get mediaExtractor;

  Iterable<ContentMediaItem>? _mediaItems;

  @override
  Future<Iterable<ContentMediaItem>> get mediaItems async {
    try {
      _mediaItems ??= await Isolate.run(
        () => mediaExtractor(),
      );
    } catch (error, stackTrace) {
      logger.w("Media items extraction error: $error", stackTrace: stackTrace);
      rethrow;
    }

    return _mediaItems!;
  }
}

mixin DLEChannelsLoader on PageableChannelsLoader {
  @override
  String nextChannelPage(String path, int page) => path + page.toString();

  @override
  bool isChannelPageable(String path) => path.endsWith("/page/");
}

mixin PageableChannelsLoader on ContentSupplier {
  String get host;
  Selector<List<Map<String, dynamic>>> get contentInfoSelector;
  Map<String, String> get channelsPath;

  @override
  Set<String> get channels => channelsPath.keys.toSet();

  @override
  Future<List<ContentInfo>> loadChannel(String channel, {page = 1}) async {
    final path = channelsPath[channel];

    if (path == null) {
      return const [];
    }

    var tragetPath = path;
    if (isChannelPageable(path)) {
      tragetPath = nextChannelPage(path, page);
    } else if (page > 1) {
      return [];
    }

    final scrapper = Scrapper(uri: Uri.https(host, tragetPath).toString());
    final results = await scrapper.scrap(contentInfoSelector) ?? [];

    return results.map(ContentSearchResult.fromJson).toList();
  }

  String nextChannelPage(String path, int page);

  bool isChannelPageable(String path);
}

mixin DLESearch on ContentSupplier {
  String get host;
  Selector<List<Map<String, dynamic>>> get contentInfoSelector;

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final uri = Uri.https(host, "/index.php");
    final scrapper = Scrapper(
      uri: uri.toString(),
      method: "post",
      headers: const {"Content-Type": "application/x-www-form-urlencoded"},
      form: {
        "do": "search",
        "subaction": "search",
        "story": query,
        "sortby": "date",
        "resorder": "desc",
      },
    );

    final results = await scrapper.scrap(contentInfoSelector) ?? [];

    return results.map(ContentSearchResult.fromJson).toList();
  }
}
