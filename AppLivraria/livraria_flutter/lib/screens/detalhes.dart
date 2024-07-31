import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_livraria_1/components/image_placehoder.dart';
import 'package:flutter_livraria_1/models/comentario.dart';
import 'package:flutter_livraria_1/models/livro.dart';
import 'package:flutter_livraria_1/models/user.dart';
import 'package:flutter_livraria_1/utils/estado.dart';
import 'package:intl/intl.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class Detalhes extends StatefulWidget {
  final int livroid;
  const Detalhes({super.key, required this.livroid});

  @override
  State<Detalhes> createState() => _DetalhesState();
}

late List<Widget> paginas;

class _DetalhesState extends State<Detalhes> {
  late Livro _livro;

  late PageController _controladorSlides;
  late int _slideSelecionado;

  late final List<Comentario> _comentariosEstaticos = [];
  late final List<Livro> _feedLivros = [];

  List<Comentario> _comentarios = [];

  bool _temComentarios = false;
  bool _carregando = false;

  late TextEditingController _controladorNovoComentario;

  bool _curtiu = false;

  @override
  void initState() {
    super.initState();

    _iniciarSlides();
    _lerFeedEstatico();

    _controladorNovoComentario = TextEditingController();
    _carregando = true;
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  Future<void> _lerFeedEstatico() async {
    String conteudoJson =
        await rootBundle.loadString("lib/data/json/livros.json");
    final livrosJson = await json.decode(conteudoJson);

    livrosJson.forEach((item) => _feedLivros.add(Livro(
        id: item["id"],
        titulo: item["titulo"],
        autor: item["autor"],
        preco: item["preco"],
        genero: item["genero"],
        likes: item["likes"],
        paginas: item["paginas"],
        sinopse: item["sinopse"],
        imagens: [item["imagens"][0]["file"], item["imagens"][1]["file"]])));

    String conteudoComentarioJson =
        await rootBundle.loadString("lib/data/json/comentarios.json");
    final comentariosJson = await json.decode(conteudoComentarioJson);

    comentariosJson["comentarios"].forEach((item) => _comentariosEstaticos.add(
        Comentario(
            id: item["_id"],
            feed: item["feed"],
            user: User(
                userId: item["user"]["userId"],
                email: item["user"]["email"],
                name: item["user"]["name"]),
            datetime: item["datetime"],
            content: item["content"])));

    _carregarLivro();
    _carregarComentarios();
  }

  void _carregarLivro() {
    setState(() {
      _livro = _feedLivros.firstWhere((livro) => livro.id == widget.livroid);
      _carregando = false;
    });
  }

  void _carregarComentarios() {
    List<Comentario> maisComentarios = [];
    _comentariosEstaticos
        .where((item) => item.feed == widget.livroid)
        .forEach((item) {
      maisComentarios.add(item);
    });

    setState(() {
      _comentarios = maisComentarios;

      _temComentarios = _comentarios.isNotEmpty;
    });
  }

  void _adicionarComentario(EstadoApp provider) {
    String conteudo = _controladorNovoComentario.text.trim();
    if (conteudo.isNotEmpty) {
      setState(() {
        _comentarios.insert(
            0,
            Comentario(
                content: conteudo,
                datetime: DateTime.now().toString(),
                feed: widget.livroid,
                id: _comentarios.length + 2,
                user: User(
                    userId: 3,
                    email: provider.usuario!.email!,
                    name: provider.usuario!.nome!)));
        _temComentarios = true;
      });

      _controladorNovoComentario.clear();
    } else {
      Toast.show("Digite um comentário",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EstadoApp>(context);

    return _carregando
        ? Scaffold(
            backgroundColor: const Color.fromARGB(255, 231, 230, 230),
            appBar: AppBar(
              title: const Text("Carregando..."),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: const Center(child: CircularProgressIndicator()))
        : Scaffold(
            appBar: AppBar(
              title: Text(_livro.titulo),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Material(
                    elevation: 4,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height / 4,
                            child: PageView.builder(
                              itemCount: _livro.imagens.length,
                              controller: _controladorSlides,
                              onPageChanged: (slide) {
                                setState(() {
                                  _slideSelecionado = slide;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ImagePlacehoder(
                                    image: _livro.imagens[index]);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: PageViewDotIndicator(
                              currentItem: _slideSelecionado,
                              count: _livro.imagens.length,
                              unselectedColor: Colors.black26,
                              selectedColor: Theme.of(context).primaryColor,
                              duration: const Duration(milliseconds: 200),
                              boxShape: BoxShape.circle,
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                _livro.titulo,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _livro.autor,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                _livro.genero,
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_stories_outlined),
                                  const SizedBox(width: 6),
                                  Text("${_livro.paginas} páginas"),
                                ],
                              ),
                              Text(
                                "R\$ ${_livro.preco}",
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Divider(
                                color: Color.fromARGB(255, 231, 230, 230),
                                thickness: 1,
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      provider.usuario != null
                                          ? IconButton(
                                              onPressed: () {
                                                if (_curtiu) {
                                                  setState(() {
                                                    _livro.likes -= 1;
                                                    _curtiu = false;
                                                  });
                                                } else {
                                                  setState(() {
                                                    _livro.likes += 1;
                                                    _curtiu = true;
                                                  });

                                                  Toast.show(
                                                      "Obrigado pela avaliação",
                                                      duration:
                                                          Toast.lengthLong,
                                                      gravity: Toast.bottom);
                                                }
                                              },
                                              icon: Icon(_curtiu
                                                  ? Icons.favorite
                                                  : Icons.favorite_border),
                                              color: _curtiu
                                                  ? Colors.red
                                                  : Colors.grey,
                                              iconSize: 20)
                                          : const SizedBox(width: 45),
                                      Text("${_livro.likes} Curtidas",
                                          style: const TextStyle(fontSize: 15))
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 20),
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text(
                              "Sinopse",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 231, 230, 230),
                              thickness: 1,
                              height: 10,
                            ),
                            Text(
                              _livro.sinopse,
                              textAlign: TextAlign.justify,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ],
                        )),
                  ),
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.only(top: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Comentários",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            color: Color.fromARGB(255, 231, 230, 230),
                            thickness: 1,
                            height: 10,
                          ),
                          provider.usuario != null
                              ? Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: TextField(
                                    controller: _controladorNovoComentario,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black87, width: 0.0),
                                      ),
                                      border: const OutlineInputBorder(),
                                      hintStyle: const TextStyle(fontSize: 14),
                                      hintText: 'Digite aqui seu comentário...',
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _adicionarComentario(provider);
                                        },
                                        child: const Icon(Icons.send,
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          SizedBox(
                              height: 400,
                              child: _temComentarios
                                  ? ListView.builder(
                                      itemCount: _comentarios.length,
                                      itemBuilder: (context, index) {
                                        String dataFormatada = DateFormat(
                                                'dd/MM/yyyy HH:mm')
                                            .format(DateTime.parse(
                                                _comentarios[index].datetime));
                                        bool usuarioLogadoComentou =
                                            provider.usuario != null &&
                                                provider.usuario!.email ==
                                                    _comentarios[index]
                                                        .user
                                                        .email;
                                        return Dismissible(
                                          key: Key(_comentarios[index]
                                              .id
                                              .toString()),
                                          direction: usuarioLogadoComentou
                                              ? DismissDirection.endToStart
                                              : DismissDirection.none,
                                          onDismissed: (direction) {
                                            if (direction ==
                                                DismissDirection.endToStart) {
                                              Comentario comentarioExcluido =
                                                  _comentarios[index];
                                              setState(() {
                                                _comentarios.removeAt(index);
                                                _temComentarios =
                                                    _comentarios.isNotEmpty;
                                              });
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext contexto) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Deseja apagar o comentário?"),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _comentarios.insert(
                                                                    index,
                                                                    comentarioExcluido);
                                                                _temComentarios =
                                                                    true;
                                                              });

                                                              Navigator.of(
                                                                      contexto)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                "NÃO")),
                                                        TextButton(
                                                            onPressed: () {
                                                              setState(() {});

                                                              Navigator.of(
                                                                      contexto)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                "SIM"))
                                                      ],
                                                    );
                                                  });
                                            }
                                          },
                                          background: Container(
                                            alignment: Alignment.centerRight,
                                            color: Colors.red,
                                            child: const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 10),
                                              child: Icon(Icons.delete,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          child: Card(
                                            color: usuarioLogadoComentou
                                                ? const Color.fromARGB(
                                                    255, 109, 125, 199)
                                                : Colors.white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                children: [
                                                  Text(_comentarios[index]
                                                      .content),
                                                  Row(
                                                    children: [
                                                      Text(_comentarios[index]
                                                          .user
                                                          .name),
                                                      const SizedBox(width: 6),
                                                      Text(dataFormatada)
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                size: 32, color: Colors.grey),
                                            Text("não existem comentários",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.grey))
                                          ]),
                                    ))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ));
  }
}
