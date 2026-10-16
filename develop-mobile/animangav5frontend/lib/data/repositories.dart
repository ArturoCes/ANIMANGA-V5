import '../core/api_client.dart';
import 'models.dart';

class AuthRepository {
  AuthRepository(this._api);
  final ApiClient _api;

  Future<(User, Session)> login(String username, String password) async =>
      _session(await _api.post('/auth/login', body: {'username': username, 'password': password}));

  Future<(User, Session)> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async =>
      _session(await _api.post('/auth/register', body: {
        'username': username,
        'fullName': fullName,
        'email': email,
        'password': password,
      }));

  Future<void> logout(String refreshToken) => _api.post('/auth/logout', body: {'refreshToken': refreshToken});

  Future<void> forgotPassword(String email) => _api.post('/auth/forgot-password', body: {'email': email});

  Future<void> resetPassword(String token, String password) =>
      _api.post('/auth/reset-password', body: {'token': token, 'password': password});

  Future<User> verifyEmail(String token) async =>
      User.fromJson(await _api.post('/auth/verify-email', body: {'token': token}) as Map<String, dynamic>);

  Future<void> resendVerification() => _api.post('/auth/verify-email/resend');

  Future<User> me() async => User.fromJson(await _api.get('/users/me') as Map<String, dynamic>);

  (User, Session) _session(dynamic json) => (
        User.fromJson(json['user'] as Map<String, dynamic>),
        Session(json['accessToken'] as String, json['refreshToken'] as String),
      );
}

class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<PageResult<MangaSummary>> search(CatalogFilter filter, {int page = 0, int size = 12}) async =>
      PageResult.fromJson(
        await _api.get('/mangas', query: {...filter.toQuery(), 'page': page, 'size': size}),
        MangaSummary.fromJson,
      );

  Future<HomeSections> home() async => HomeSections.fromJson(await _api.get('/mangas/home') as Map<String, dynamic>);

  Future<List<Category>> categories() async =>
      (await _api.get('/categories') as List).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();

  Future<List<String>> publishers() async => (await _api.get('/mangas/publishers') as List).cast<String>();

  Future<MangaDetail> manga(String id) async =>
      MangaDetail.fromJson(await _api.get('/mangas/$id') as Map<String, dynamic>);

  Future<PageResult<Review>> reviews(String mangaId, {int page = 0, int size = 5}) async => PageResult.fromJson(
        await _api.get('/mangas/$mangaId/reviews', query: {'page': page, 'size': size}),
        Review.fromJson,
      );

  Future<void> rate(String mangaId, int rating, String? comment) =>
      _api.post('/mangas/$mangaId/reviews', body: {'rating': rating, 'comment': comment});

  Future<void> deleteReview(String reviewId) => _api.delete('/reviews/$reviewId');

  Future<List<MangaSummary>> favorites() async => (await _api.get('/users/me/favorites') as List)
      .map((e) => MangaSummary.fromJson(e as Map<String, dynamic>))
      .toList();

  Future<void> setFavorite(String mangaId, bool favorite) =>
      favorite ? _api.put('/users/me/favorites/$mangaId') : _api.delete('/users/me/favorites/$mangaId');
}

class ShopRepository {
  ShopRepository(this._api);
  final ApiClient _api;

  Future<Cart> cart() async => Cart.fromJson(await _api.get('/cart') as Map<String, dynamic>);

  Future<Cart> add(String volumeId, {int quantity = 1}) async => Cart.fromJson(
      await _api.post('/cart/items', body: {'volumeId': volumeId, 'quantity': quantity}) as Map<String, dynamic>);

  Future<Cart> setQuantity(String volumeId, int quantity) async =>
      Cart.fromJson(await _api.put('/cart/items/$volumeId', body: {'quantity': quantity}) as Map<String, dynamic>);

  Future<Cart> remove(String volumeId) async =>
      Cart.fromJson(await _api.delete('/cart/items/$volumeId') as Map<String, dynamic>);

  Future<Order> checkout({
    required ShippingAddress shipping,
    required String cardNumber,
    required String cardExpiry,
    required String cardCvc,
  }) async =>
      Order.fromJson(await _api.post('/orders', body: {
        'shipping': shipping.toJson(),
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
        'cardCvc': cardCvc,
      }) as Map<String, dynamic>);

  Future<PageResult<Order>> myOrders({int page = 0}) async =>
      PageResult.fromJson(await _api.get('/orders/me', query: {'page': page, 'size': 20}), Order.fromJson);

  Future<Order> order(String id) async => Order.fromJson(await _api.get('/orders/$id') as Map<String, dynamic>);

  Future<Order> cancel(String id) async =>
      Order.fromJson(await _api.post('/orders/$id/cancel') as Map<String, dynamic>);
}

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<User> update({required String fullName, required String email}) async =>
      User.fromJson(await _api.put('/users/me', body: {'fullName': fullName, 'email': email}) as Map<String, dynamic>);

  Future<User> updateAvatar(UploadFile image) async =>
      User.fromJson(await _api.multipart('PUT', '/users/me/avatar', files: {'image': image}) as Map<String, dynamic>);

  Future<void> changePassword(String current, String newPassword) =>
      _api.put('/users/me/password', body: {'currentPassword': current, 'newPassword': newPassword});
}
