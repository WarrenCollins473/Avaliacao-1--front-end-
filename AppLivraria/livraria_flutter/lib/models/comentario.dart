import 'package:flutter_livraria_1/models/user.dart';

class Comentario {
  final int id;
  final int feed;
  final User user;
  final String datetime;
  final String content;

  Comentario(
      {required this.id,
      required this.feed,
      required this.user,
      required this.datetime,
      required this.content});
}
