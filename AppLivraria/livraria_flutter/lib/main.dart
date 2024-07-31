import 'package:flutter/material.dart';
import 'package:flutter_livraria_1/screens/feed_livros.dart';
import 'package:flutter_livraria_1/utils/estado.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EstadoApp(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Livraria',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 64, 13, 73),
              brightness: Brightness.light,
              primary: const Color.fromARGB(255, 64, 13, 73),
              background: Colors.indigo[50]),
          appBarTheme: const AppBarTheme(
              color: Color.fromARGB(255, 64, 13, 73),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: "Sedan",
              )),
          fontFamily: "GentiumBookPlus",
        ),
        home: const FeedLivros(),
      ),
    );
  }
}
