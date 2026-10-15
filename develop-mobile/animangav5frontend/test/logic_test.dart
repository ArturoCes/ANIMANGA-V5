import 'package:animanga/data/models.dart';
import 'package:animanga/ui/cart/checkout_sheet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validación de tarjeta (Luhn)', () {
    test('acepta tarjetas de prueba válidas', () {
      expect(isValidCard('4242 4242 4242 4242'), isTrue);
      expect(isValidCard('5555555555554444'), isTrue);
    });

    test('rechaza números incorrectos', () {
      expect(isValidCard('4242 4242 4242 4241'), isFalse);
      expect(isValidCard('1234'), isFalse);
      expect(isValidCard(''), isFalse);
    });
  });

  group('Modelos', () {
    test('Manga ordena los volúmenes de forma natural y calcula el precio mínimo', () {
      final manga = Manga.fromJson({
        'id': 'm1',
        'name': 'Jujutsu Kaisen',
        'categories': [
          {'id': 'c1', 'name': 'Shōnen'},
        ],
        'volumenes': [
          {'id': 'v10', 'nombre': 'Jujutsu Kaisen 10', 'precio': 8.95, 'cantidad': 0},
          {'id': 'v2', 'nombre': 'Jujutsu Kaisen 2', 'precio': 8.5, 'cantidad': 3},
        ],
      });

      expect(manga.volumenes.map((v) => v.nombre), ['Jujutsu Kaisen 2', 'Jujutsu Kaisen 10']);
      expect(manga.minPrice, 8.5);
      expect(manga.volumenes.last.soldOut, isTrue);
    });

    test('PageResult lee contenido y total', () {
      final page = PageResult.fromJson({
        'content': [
          {'id': 'c1', 'name': 'Acción', 'description': ''},
        ],
        'totalElements': 1,
        'last': true,
      }, Category.fromJson);

      expect(page.totalElements, 1);
      expect(page.content.single.name, 'Acción');
    });
  });
}
