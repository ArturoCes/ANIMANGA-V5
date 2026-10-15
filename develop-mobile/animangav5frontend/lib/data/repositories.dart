import '../core/api_client.dart';
import 'models.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  /// Devuelve el usuario y deja el token configurado en el cliente.
  Future<User> login(String username, String password) async {
    final json = await _api.post('/auth/login', body: {'username': username, 'password': password});
    _api.token = json['token'] as String;
    return User.fromJson(json as Map<String, dynamic>);
  }

  Future<void> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) =>
      _api.post('/auth/register', body: {
        'username': username,
        'fullName': fullName,
        'email': email,
        'password': password,
        'verifyPassword': password,
      });

  Future<User> me() async => User.fromJson(await _api.get('/me') as Map<String, dynamic>);
}

class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<PageResult<Manga>> mangas({int page = 0, int size = 20}) async =>
      PageResult.fromJson(await _api.get('/manga/all', query: {'page': page, 'size': size}), Manga.fromJson);

  Future<PageResult<Manga>> search(String name, {int page = 0, int size = 20}) async => PageResult.fromJson(
        await _api.multipart('POST', '/manga/search/all', jsonParts: {
          'search': {'name': name}
        }, query: {
          'page': page,
          'size': size
        }),
        Manga.fromJson,
      );

  Future<PageResult<Manga>> byCategory(String category, {int page = 0, int size = 20}) async => PageResult.fromJson(
        await _api.get('/manga/all/categories/${Uri.encodeComponent(category)}', query: {'page': page, 'size': size}),
        Manga.fromJson,
      );

  Future<List<Category>> categories() async =>
      PageResult.fromJson(await _api.get('/category/all', query: {'size': 100}), Category.fromJson).content;

  Future<Manga> manga(String id) async => Manga.fromJson(await _api.get('/manga/$id') as Map<String, dynamic>);

  Future<List<Character>> characters(String mangaId) async =>
      PageResult.fromJson(await _api.get('/manga/$mangaId/characters', query: {'size': 50}), Character.fromJson)
          .content;

  Future<bool> isFavorite(String mangaId) async =>
      (await _api.get('/manga/favorite/bool/$mangaId'))['favorito'] as bool? ?? false;

  Future<void> setFavorite(String mangaId, bool favorite) =>
      _api.post(favorite ? '/manga/favorite/$mangaId' : '/manga/favorite/remove/$mangaId');

  Future<List<Manga>> favorites(String username) async =>
      PageResult.fromJson(await _api.get('/manga/all/favorite/$username', query: {'size': 100}), Manga.fromJson)
          .content;
}

class ShopRepository {
  ShopRepository(this._api);
  final ApiClient _api;

  Future<List<CartItem>> cart(String cartId) async =>
      PageResult.fromJson(await _api.get('/cart/$cartId', query: {'size': 100}), CartItem.fromJson).content;

  Future<void> addToCart(String userId, String volumenId) => _api.post('/cart/$userId/items/$volumenId');

  Future<void> removeOne(String userId, String volumenId) => _api.post('/cart/$userId/items/remove/$volumenId');

  Future<void> checkout(String cartId, String cardNumber) =>
      _api.post('/purchase/new', body: {'idCart': cartId, 'numCreditCard': cardNumber});

  Future<List<Purchase>> myPurchases() async =>
      PageResult.fromJson(await _api.get('/purchase/me', query: {'size': 100}), Purchase.fromJson).content;
}

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<User> update(User user, {required String fullName, required String email}) async => User.fromJson(
        await _api.multipart('PUT', '/user/${user.id}', jsonParts: {
          'user': {'fullName': fullName, 'email': email, 'username': user.username},
        }) as Map<String, dynamic>,
      );

  Future<User> updateAvatar(String userId, UploadFile image) async =>
      User.fromJson(await _api.multipart('PUT', '/image/$userId', files: {'image': image}) as Map<String, dynamic>);

  Future<void> changePassword(String current, String newPassword) => _api.multipart('PUT', '/change', jsonParts: {
        'user': {'password': current, 'passwordNew': newPassword, 'passwordNewVerify': newPassword},
      });
}
