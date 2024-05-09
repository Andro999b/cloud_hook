import 'package:cloud_hook/content_suppliers/impl/ua_films_tv.dart';
import 'package:test/test.dart';

void main() {
  group("UAFilmTV", () {
    test('should return content', () async {
      const id = "18236-delicious-in-dungeon";
      final supplier = UAFilmsTVSupplier();

      final details = await supplier.detailsById(id);

      expect(details.id, id);
      expect(details.supplier, supplier.name);
      expect(details.title, "Підземелля смакоти");
      expect(details.oroginalTitle, "Delicious in Dungeon");
    });
  });
}
