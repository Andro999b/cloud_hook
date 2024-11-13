import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_ffi/bundle.dart';
import 'package:flutter/material.dart';
import 'package:test/test.dart';

const libDirectory = "rust/target/release";
const libName = "libcontent_suppliers_ffi";

void main() async {
  final bundle = FFIContentSuppliersBundle(
    libPath: "rust/target/release/libcontent_suppliers_ffi.so",
  );

  await bundle.load();

  final suppliers = await bundle.suppliers;
  test("should return avalaible suppliers", () async {
    expect(suppliers.length, equals(1));
    expect(suppliers.map((v) => v.name).toList(), equals(["dummy"]));
  });

  test("should retun channels", () async {
    final supplier = suppliers.first;
    final channels = supplier.channels;

    expect(channels, equals(["dummy_channel"]));
  });

  test("should retun default channels", () async {
    final supplier = suppliers.first;
    final channels = supplier.defaultChannels;

    expect(channels, equals(["dummy_channel"]));
  });

  test("should retun supported types", () async {
    final supplier = suppliers.first;
    final types = supplier.supportedTypes;

    expect(types, equals({ContentType.movie, ContentType.anime}));
  });

  test("should retun supported languges", () async {
    final supplier = suppliers.first;
    final types = supplier.supportedLanguages;

    expect(types, equals({ContentLanguage.en, ContentLanguage.uk}));
  });

  test("should load search results", () async {
    const query = "test";
    final type = {ContentType.anime};

    final supplier = suppliers.first;
    final results = await supplier.search(query, type);

    expect(results.length, equals(1));

    final searchResult = results.first;

    expect(searchResult.id, equals(query));
    expect(searchResult.supplier, equals("dummy"));
    expect(searchResult.title, equals(type.map((t) => t.index).join(",")));
    expect(searchResult.secondaryTitle, equals("secondary_dummy_title"));
    expect(searchResult.image, equals("dummy_image"));
  });

  test("should load channels", () async {
    const channel = "dummy_channel";
    const page = 10;

    final supplier = suppliers.first;
    final items = await supplier.loadChannel(channel, page: page);

    expect(items.length, equals(1));

    final channelItem = items.first;

    expect(channelItem.id, equals("$channel $page"));
    expect(channelItem.supplier, equals("dummy"));
    expect(channelItem.title, equals("dummy_title"));
    expect(channelItem.secondaryTitle, equals("secondary_dummy_title"));
    expect(channelItem.image, equals("dummy_image"));
  });

  test("should return error", () async {
    const channel = "unknown_channel";

    final supplier = suppliers.first;

    expect(
      () => supplier.loadChannel(channel, page: 0),
      throwsException,
    );
  });

  test("should load content details", () async {
    const id = "dummy_id";

    final supplier = suppliers.first;
    final details = await supplier.detailsById(id);

    expect(details, isNotNull);
    expect(details!.id, equals(id));
    expect(details.supplier, equals("dummy"));
    expect(details.title, equals("dummy_title"));
    expect(details.originalTitle, equals("original_dummy_title"));
    expect(details.image, equals("dummy_image"));
    expect(details.description, equals("dummy_description"));
    expect(details.mediaType, equals(MediaType.video));
    expect(
      details.additionalInfo,
      equals(["dummy_additional_info1", "dummy_additional_info2"]),
    );
    expect(details.similar.length, equals(1));

    final similar = details.similar.first;
    expect(similar.id, equals("dummy_similar"));
    expect(similar.supplier, equals("dummy"));
    expect(similar.title, equals("dummy_title"));
    expect(similar.secondaryTitle, equals("secondary_dummy_title"));
    expect(similar.image, equals("dummy_image"));

    final mediaItems = await details.mediaItems;
    expect(mediaItems.length, equals(1));

    final mediaItem = mediaItems.first;
    expect(mediaItem.number, equals(42));
    expect(mediaItem.title, equals(id));
    expect(mediaItem.section, equals("1,2,3"));
    expect(mediaItem.image, equals("dummy_image"));

    final sources = await mediaItem.sources;
    expect(sources.length, equals(3));

    expect(sources[0], isA<MediaFileItemSource>());
    final videoSource = sources[0] as MediaFileItemSource;

    expect(await videoSource.link, equals(Uri.parse("http://dummy_link")));
    expect(videoSource.kind, equals(FileKind.video));
    expect(videoSource.description, equals("$id 1,2,3"));
    expect(videoSource.headers, equals({"User-Agent": "dummy"}));

    expect(sources[1], isA<MediaFileItemSource>());
    final subtitleSource = sources[1] as MediaFileItemSource;

    expect(await subtitleSource.link, equals(Uri.parse("http://dummy_link")));
    expect(subtitleSource.kind, equals(FileKind.subtitle));
    expect(subtitleSource.description, equals("$id 1,2,3"));
    expect(subtitleSource.headers, equals({"User-Agent": "dummy"}));

    expect(sources[2], isA<MangaMediaItemSource>());
    final mangaSource = sources[2] as MangaMediaItemSource;

    expect(
        await mangaSource.allPages(),
        equals([
          const NetworkImage("http://page1"),
          const NetworkImage("http://page2"),
        ]));
    expect(mangaSource.kind, equals(FileKind.manga));
    expect(mangaSource.description, equals("$id 1,2,3"));
    expect(mangaSource.pageNambers, equals(2));
  });
}
