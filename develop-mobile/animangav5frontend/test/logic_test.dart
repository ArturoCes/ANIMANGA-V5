import 'package:animanga/data/models.dart';
import 'package:animanga/ui/cart/checkout_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validación de tarjeta', () {
    test('acepta tarjetas de prueba válidas (Luhn)', () {
      expect(isValidCard('4242 4242 4242 4242'), isTrue);
      expect(isValidCard('5555555555554444'), isTrue);
    });

    test('rechaza números incorrectos', () {
      expect(isValidCard('4242 4242 4242 4241'), isFalse);
      expect(isValidCard('1234'), isFalse);
      expect(isValidCard(''), isFalse);
    });

    test('valida la caducidad', () {
      final now = DateTime(2026, 10, 16);
      expect(isValidExpiry('10/26', now), isTrue);
      expect(isValidExpiry('12/30', now), isTrue);
      expect(isValidExpiry('09/26', now), isFalse);
      expect(isValidExpiry('13/28', now), isFalse);
      expect(isValidExpiry('1228', now), isFalse);
    });
  });

  group('Modelos', () {
    test('el resultado de buscar por imagen indica si hay coincidencia', () {
      final r = ImageSearchResult.fromJson({
        'found': true,
        'matches': [
          {'manga': {'id': 'm1', 'title': 'Naruto'}, 'volumeNumber': 1, 'cover': 'nar-01.jpg', 'similarity': 97},
        ],
      });
      expect(r.found, isTrue);
      expect(r.matches.single.manga.title, 'Naruto');
      expect(r.matches.single.volumeNumber, 1);
    });

    test('el volumen lee las páginas del avance', () {
      final v = Volume.fromJson({'id': 'v1', 'previewPages': ['a-p01.jpg', 'a-p02.jpg']});
      expect(v.hasPreview, isTrue);
      expect(v.previewPages, ['a-p01.jpg', 'a-p02.jpg']);
      expect(Volume.fromJson({'id': 'v2'}).hasPreview, isFalse);
    });

    test('MangaDetail lee volúmenes, personajes y valoración', () {
      final manga = MangaDetail.fromJson({
        'id': 'm1',
        'title': 'Spy×Family',
        'author': 'Tatsuya Endō',
        'categories': [
          {'id': 'c1', 'name': 'Comedia'},
        ],
        'minPrice': 9,
        'ratingAverage': 4.5,
        'ratingCount': 2,
        'inStock': true,
        'synopsis': 'Una familia muy especial.',
        'volumes': [
          {'id': 'v1', 'number': 1, 'title': 'Spy×Family 1', 'price': 9.0, 'stock': 0},
        ],
        'characters': [
          {'id': 'p1', 'name': 'Anya Forger', 'age': 6},
        ],
        'favorite': true,
        'myRating': 5,
      });

      expect(manga.categories, ['Comedia']);
      expect(manga.minPrice, 9.0);
      expect(manga.volumes.single.soldOut, isTrue);
      expect(manga.characters.single.name, 'Anya Forger');
      expect(manga.favorite, isTrue);
      expect(manga.myRating, 5);
    });

    test('Cart calcula unidades por volumen', () {
      final cart = Cart.fromJson({
        'items': [
          {
            'volume': {'id': 'v1', 'title': 'Naruto 1', 'price': 8.95, 'stock': 10},
            'quantity': 2,
            'subtotal': 17.9,
          },
        ],
        'totalItems': 2,
        'total': 17.9,
      });
      expect(cart.quantityOf('v1'), 2);
      expect(cart.quantityOf('otro'), 0);
      expect(cart.total, 17.9);
    });

    test('Los filtros solo envían los parámetros activos', () {
      const filter = CatalogFilter(q: ' naruto ', category: 'Shōnen', inStock: true, sort: 'rating');
      expect(filter.activeCount, 2);
      expect(filter.toQuery(), containsPair('q', 'naruto'));
      expect(filter.toQuery()['publisher'], isNull);
      expect(filter.copyWith(category: () => null).activeCount, 1);
    });

    test('Order interpreta el estado', () {
      expect(OrderStatus.parse('SHIPPED'), OrderStatus.shipped);
      expect(OrderStatus.parse('DELIVERED').label, 'Entregado');
    });
  });
}
