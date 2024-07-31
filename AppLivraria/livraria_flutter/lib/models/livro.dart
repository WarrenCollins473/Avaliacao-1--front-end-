class Livro {
  final int id;
  final String titulo;
  final String autor;
  final String preco;
  final String genero;
  int likes;
  final String paginas;
  final String sinopse;
  final List<String> imagens;

  Livro(
      {required this.id,
      required this.titulo,
      required this.autor,
      required this.preco,
      required this.likes,
      required this.paginas,
      required this.genero,
      required this.sinopse,
      required this.imagens});
}
