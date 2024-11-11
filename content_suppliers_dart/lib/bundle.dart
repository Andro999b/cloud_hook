import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/suppliers/animeua/animeua.dart';
import 'package:content_suppliers_dart/suppliers/anitaku/anitaku.dart';
import 'package:content_suppliers_dart/suppliers/anitube/anitube.dart';
import 'package:content_suppliers_dart/suppliers/hianime/hianime.dart';
import 'package:content_suppliers_dart/suppliers/mangadex/mangadex.dart';
import 'package:content_suppliers_dart/suppliers/tmdb/tmdb.dart';
import 'package:content_suppliers_dart/suppliers/uafilms/uafilms.dart';
import 'package:content_suppliers_dart/suppliers/uakinoclub/uakinoclub.dart';
import 'package:content_suppliers_dart/suppliers/uaserial/uaserial.dart';
import 'package:content_suppliers_dart/suppliers/ufdub/ufdub.dart';

class DartContentSupplierBundle implements ContentSupplierBundle {
  final String tmdbSecret;

  DartContentSupplierBundle({
    required this.tmdbSecret,
  });

  @override
  Future<List<ContentSupplier>> get suppliers => Future.value([
        TmdbSupplier(secret: tmdbSecret),
        Anitaku(),
        HianimeSupplier(),
        MangaDexSupllier(),
        UASerialSupplier(),
        UAKinoClubSupplier(),
        AniTubeSupplier(),
        AnimeUASupplier(),
        UAFilmsSupplier(),
        UFDubSupplier(),
      ]);
}
