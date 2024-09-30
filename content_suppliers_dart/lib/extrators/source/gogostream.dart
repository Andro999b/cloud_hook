import 'dart:async';
import 'dart:convert';

import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/extrators/jwplayer/jwplayer.dart';
import 'package:content_suppliers_dart/scrapper/scrapper.dart';
import 'package:content_suppliers_dart/scrapper/selectors.dart';
import 'package:content_suppliers_dart/utils.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encryption;
import 'package:json_annotation/json_annotation.dart';

part 'gogostream.g.dart';

class GogoStreamSourceLoader implements ContentMediaItemSourceLoader {
  final String url;
  final String? descriptionPrefix;

  GogoStreamSourceLoader({
    required this.url,
    this.descriptionPrefix,
  });

  @override
  FutureOr<List<ContentMediaItemSource>> call() async {
    final serverUri = Uri.parse(url);
    final res = await Scrapper(uri: serverUri).scrap(
          SelectorsToMap({
            "iv": Transform(
              item: ClassNames.forScope("div.wrapper"),
              map: (classes) => _findKey("container-", classes),
            ),
            "secretKey": Transform(
              item: ClassNames.forScope("body"),
              map: (classes) => _findKey("container-", classes),
            ),
            "decryptionKey": Transform(
              item: ClassNames.forScope("div.videocontent"),
              map: (classes) => _findKey("videocontent-", classes),
            ),
            "data": Attribute.forScope("script[data-value]", "data-value")
          }),
          rootElementSelector: (document) => document.body!.parent!,
        ) ??
        const {};

    final iv = res['iv'] as String?;
    final secretKey = res['secretKey'] as String?;
    final decryptionKey = res['decryptionKey'] as String?;
    final data = res['data'] as String?;

    if (iv == null ||
        secretKey == null ||
        decryptionKey == null ||
        data == null) {
      logger.w(
        "[gogostream] no ecritpion params "
        "iv: $iv, secretKey: $secretKey, decryptionKey: $decryptionKey, data: $data",
      );
      return [];
    }

    String decryptedAjaxParams = decrypt(data, iv, secretKey);
    decryptedAjaxParams = decryptedAjaxParams.substring(
      decryptedAjaxParams.indexOf("&") + 1,
    );

    final id = serverUri.queryParameters['id']!;
    final encryptedId = encrypt(id, iv, secretKey);

    final linksRes = await dio.get(
      "https://${serverUri.authority}/encrypt-ajax.php?"
      "id=$encryptedId&$decryptedAjaxParams&alias=$id",
      options: Options(
        headers: {
          ...defaultHeaders,
          "X-Requested-With": "XMLHttpRequest",
        },
      ),
    );

    final encryptedLinksJson = json.decode(linksRes.data)['data'];
    final jwpConfig = decrypt(encryptedLinksJson, iv, decryptionKey);

    return JWPlayer.fromConfig(
      LinksConfig.fromJson(json.decode(jwpConfig)).jwPlayerConfig,
      despriptionPrefix: descriptionPrefix,
      headers: {
        "Referer": url,
      },
    );
  }

  String? _findKey(String prefix, List<String> classes) {
    return classes
        .where((cls) => cls.startsWith(prefix))
        .map((cls) => cls.substring(prefix.length))
        .firstOrNull;
  }

  String encrypt(String data, String iv, String key) {
    final encrypter = encryption.Encrypter(encryption.AES(
      encryption.Key(utf8.encode(key)),
      mode: encryption.AESMode.cbc,
      padding: "PKCS7",
    ));

    return encrypter.encrypt(data, iv: encryption.IV(utf8.encode(iv))).base64;
  }

  String decrypt(String encrypted, String iv, String key) {
    final encrypter = encryption.Encrypter(encryption.AES(
      encryption.Key(utf8.encode(key)),
      mode: encryption.AESMode.cbc,
      padding: "PKCS7",
    ));

    return encrypter.decrypt64(encrypted, iv: encryption.IV(utf8.encode(iv)));
  }
}

@JsonSerializable(createToJson: false)
class LinksConfig {
  final List<Source> source;
  @JsonKey(name: "source_bk")
  final List<Source> sourceBk;
  final List<Track> track;

  const LinksConfig({
    required this.source,
    required this.sourceBk,
    required this.track,
  });

  factory LinksConfig.fromJson(Map<String, dynamic> json) =>
      _$LinksConfigFromJson(json);

  JWPlayerConfig get jwPlayerConfig {
    return JWPlayerConfig(
      sources: source + sourceBk,
      tracks: track,
    );
  }
}
