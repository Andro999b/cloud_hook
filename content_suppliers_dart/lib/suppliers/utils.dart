import 'dart:isolate';

import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/extrators/playerjs/playerjs.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'package:json_annotation/json_annotation.dart';

mixin PLayerJSIframe {
  String get iframe;
  @JsonKey(
    includeFromJson: false,
    includeToJson: false,
  )
  ContentMediaItemLoader get mediaExtractor =>
      PlayerJSExtractor(iframe, DubSeasonEpisodeConvertStrategy());
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
  Selector get channelInfoSelector;
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

    final scrapper = Scrapper(uri: Uri.https(host, tragetPath));
    final results = (await scrapper.scrap(channelInfoSelector) ?? [])
        as List<Map<String, dynamic>>;

    return results.map(ContentSearchResult.fromJson).toList();
  }

  String nextChannelPage(String path, int page);

  bool isChannelPageable(String path);
}

mixin DLESearch on ContentSupplier {
  String get host;
  Selector get contentInfoSelector;

  @override
  Future<List<ContentSearchResult>> search(
    String query,
    Set<ContentType> type,
  ) async {
    final scrapper = Scrapper(
      uri: Uri.https(host, "/index.php"),
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

    final results = (await scrapper.scrap(contentInfoSelector) ?? [])
        as List<Map<String, dynamic>>;

    return results.map(ContentSearchResult.fromJson).toList();
  }
}
