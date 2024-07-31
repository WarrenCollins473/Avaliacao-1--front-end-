import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_livraria_1/components/livro_item.dart';
import 'package:flutter_livraria_1/models/livro.dart';
import 'package:flutter_livraria_1/utils/autenticador.dart';
import 'package:flutter_livraria_1/utils/estado.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class FeedLivros extends StatefulWidget {
  const FeedLivros({super.key});

  @override
  State<FeedLivros> createState() => _FeedLivrosState();
}

class _FeedLivrosState extends State<FeedLivros> {
  late dynamic livrosJson;
  late final List<Livro> _feedlivros = [];
  late List<Livro> _livros = [];
  bool _carregando = false;
  final ScrollController _scrollController = ScrollController();
  final int _tamanhoPagina = 8;
  int _proximaPagina = 1;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);
    _scrollController.addListener(_scrollListener);
    _lerFeedLivros().then((_) {
      _carregarLivrosFeed();
    }).then((_) {
      _carregarLivros();
    });
  }

  Future<void> _lerFeedLivros() async {
    final conteudoJson =
        await rootBundle.loadString("lib/data/json/livros.json");
    livrosJson = await jsonDecode(conteudoJson);
  }

  void _carregarLivrosFeed() {
    setState(() {
      livrosJson.forEach((item) {
        bool contem = _feedlivros.any((livro) => livro.id == item["id"]);
        if (!contem) {
          _feedlivros.add(Livro(
              id: item["id"],
              titulo: item["titulo"],
              autor: item["autor"],
              preco: item["preco"],
              genero: item["genero"],
              likes: item["likes"],
              paginas: item["paginas"],
              sinopse: item["sinopse"],
              imagens: [
                item["imagens"][0]["file"],
                item["imagens"][1]["file"]
              ]));
        }
      });
    });
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _carregando = true;

        if (_carregando) {
          _carregarLivros();
        }
      });
    }
  }

  void _carregarLivros() {
    setState(() {
      _carregando = true;
    });

    List<Livro> maisLivros = [];
    // Lazyload
    final totalLivrosParaCarregar = _proximaPagina * _tamanhoPagina;
    if (_feedlivros.length >= totalLivrosParaCarregar) {
      maisLivros = _feedlivros.sublist(0, totalLivrosParaCarregar);
    } else {
      maisLivros = _feedlivros.sublist(0, _feedlivros.length);
    }

    setState(() {
      _livros = maisLivros;
      _proximaPagina = _proximaPagina + 1;

      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EstadoApp>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Collins's Books"),
        actions: [
          provider.usuario != null
              ? IconButton(
                  onPressed: () {
                    Autenticador.logout().then((_) {
                      setState(() {
                        provider.onLogout();
                      });
                      Toast.show("Você não está mais conectado",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    });
                  },
                  icon: const Icon(
                    Icons.logout,
                    color: Colors.white,
                  ))
              : IconButton(
                  onPressed: () {
                    Autenticador.login().then((usuario) {
                      setState(() {
                        provider.onLogin(usuario);
                      });

                      Toast.show("Você foi conectado com sucesso",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    });
                  },
                  icon: const Icon(
                    Icons.login,
                    color: Colors.white,
                  ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: RefreshIndicator(
          onRefresh: _lerFeedLivros,
          child: GridView.builder(
            controller: _scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 1 / 1.5),
            itemCount: _livros.length,
            itemBuilder: (_, index) {
              return LivroItem(livro: _feedlivros[index]);
            },
          ),
        ),
      ),
    );
  }
}
