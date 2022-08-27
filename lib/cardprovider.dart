import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:appwrite/appwrite.dart';
import 'package:tinder_app/api/info.dart';

enum CardStatus { like, dislike, superlike }

class CardProvider extends ChangeNotifier {
  List<String> _assetImages = [];
  bool _isDragging = false;
  double _angle = 0;
  Offset _position = Offset.zero;
  Size _screenSize = Size.zero;

  late final Client _client;
  late final Account _account;
  late final Databases _databases;

  List<String> get assetImages => _assetImages;
  bool get isDragging => _isDragging;
  Offset get position => _position;
  double get angle => _angle;

  CardProvider() {
    initialize();
  }

  void setScreenSize(Size screenSize) => _screenSize = screenSize;

  void startPosition(DragStartDetails details) {
    _isDragging = true;

    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;
    final x = _position.dx;
    _angle = 45 * x / _screenSize.width;

    notifyListeners();
  }

  void endPosition() async {
    _isDragging = false;
    notifyListeners();

    final status = getStatus();

    final check = status.toString().split('.').last.toUpperCase();

    if (status != null) {
      Fluttertoast.cancel();
      Fluttertoast.showToast(
        msg: check,
        fontSize: 36,
      );
      try {
        await _databases.createDocument(
          collectionId: 'images',
          documentId: 'unique()',
          data: {'message': check},
        );
      } catch (e) {
        debugPrint('Eror while creating record:$e');
      }
    }

    switch (status) {
      case CardStatus.like:
        like();
        break;
      case CardStatus.dislike:
        dislike();
        break;
      case CardStatus.superlike:
        superlike();
        break;
      default:
        resetPosition();
    }
  }

  void resetPosition() {
    _isDragging = false;
    _position = Offset.zero;
    _angle = 0;
    notifyListeners();
  }

  CardStatus? getStatus() {
    final x = _position.dx;
    final y = _position.dy;
    final forceSuperLike = x.abs() < 20;

    final delta = 100;

    if (x >= delta) {
      return CardStatus.like;
    } else if (x <= -delta) {
      return CardStatus.dislike;
    } else if (y <= -delta / 2 && forceSuperLike) {
      return CardStatus.superlike;
    }
  }

  void dislike() {
    _angle = -20;
    _position -= Offset(2 * _screenSize.width, 0);
    _nextImage();

    notifyListeners();
  }

  void like() {
    _angle = 20;
    _position += Offset(2 * _screenSize.width, 0);
    _nextImage();

    notifyListeners();
  }

  void superlike() {
    _angle = 0;
    _position -= Offset(0, _screenSize.height);
    _nextImage();

    notifyListeners();
  }

  Future _nextImage() async {
    if (_assetImages.isEmpty) return;

    await Future.delayed(const Duration(milliseconds: 200));
    _assetImages.removeLast();
    resetPosition();
  }

  void initialize() {
    _client = Client()
      ..setEndpoint(endpoint)
      ..setProject(projectid);
    _account = Account(_client);
    _databases = Databases(_client, databaseId: databaseid);
    userimages();
  }

  void userimages() async {
    try {
      await _account.get();
    } catch (_) {
      await _account.createAnonymousSession();
    }
    _assetImages = <String>[
      'http://localhost/v1/storage/buckets/images/files/4/preview?project=tinder',
      'http://localhost/v1/storage/buckets/images/files/2/preview?project=tinder',
      'http://localhost/v1/storage/buckets/images/files/3/preview?project=tinder',
      'http://localhost/v1/storage/buckets/images/files/1/preview?project=tinder',
    ].reversed.toList();
    notifyListeners();
  }
}
