// ... [importações continuam iguais]
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myapp/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://jpqnzgbrrxrxuhriwwjj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpwcW56Z2JycnhyeHVocml3d2pqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA4NDM5NTYsImV4cCI6MjA3NjQxOTk1Nn0.vMKR0s2xNIEfspDP7k7_LdFbcK4hW7qGrDVsIEexJhk',
  );

  runApp(const MaterialApp(home: CadastroProduto()));
}

class CadastroProduto extends StatefulWidget {
  const CadastroProduto({super.key});

  @override
  State<CadastroProduto> createState() => _CadastroProdutoState();
}

class _CadastroProdutoState extends State<CadastroProduto> {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final precoController = TextEditingController();

  final urlImagemController = TextEditingController();
  List<String> urlsImagens = [];

  String tipoTamanho = 'numerico';

  final Map<String, TextEditingController> tamanhosNumericos = {};
  List<Map<String, dynamic>> variacoes = [];

  void adicionarVariacao() {
    setState(() {
      variacoes.add({'cor': '', 'tamanhos': <String, TextEditingController>{}});
    });
  }

  void removerVariacao(int index) {
    setState(() {
      variacoes.removeAt(index);
    });
  }

  final Map<String, TextEditingController> tamanhosPMG = {
    'P': TextEditingController(),
    'M': TextEditingController(),
    'G': TextEditingController(),
  };

  final TextEditingController tamanhosNumericosController =
      TextEditingController();

  bool possuiVariacoesCor = false;
  final TextEditingController coresController = TextEditingController();

  Future<void> _salvarProduto() async {
    final nome = nomeController.text.trim();
    final descricao = descricaoController.text.trim();
    final precoStr = precoController.text.trim();

    if (nome.isEmpty ||
        descricao.isEmpty ||
        precoStr.isEmpty ||
        urlsImagens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos obrigatórios.")),
      );
      return;
    }

    double preco;
    try {
      preco = double.parse(precoStr);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preço inválido.")),
      );
      return;
    }

    Map<String, dynamic> variacoesMap = {};

    if (possuiVariacoesCor) {
      for (final corData in variacoes) {
        final cor = corData['cor'];
        if (cor == null || cor.isEmpty) continue;

        final tamanhos =
            corData['tamanhos'] as Map<String, TextEditingController>;
        final estoquePorTamanho = <String, int>{};

        tamanhos.forEach((tamanho, controller) {
          final qtdStr = controller.text.trim();
          if (qtdStr.isNotEmpty) {
            final qtd = int.tryParse(qtdStr) ?? 0;
            if (qtd > 0) {
              estoquePorTamanho[tamanho] = qtd;
            }
          }
        });

        if (estoquePorTamanho.isNotEmpty) {
          variacoesMap[cor] = estoquePorTamanho;
        }
      }

      if (variacoesMap.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Adicione pelo menos uma variação de cor e tamanho com estoque.")),
        );
        return;
      }
    }

    try {
      await FirebaseFirestore.instance.collection('estoque').add({
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'imagens': urlsImagens,
        'variacoes': possuiVariacoesCor ? variacoesMap : {},
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto cadastrado com sucesso!")),
      );

      nomeController.clear();
      descricaoController.clear();
      precoController.clear();
      urlImagemController.clear();
      urlsImagens.clear();
      coresController.clear();
      tamanhosNumericos.clear();
      tamanhosPMG.values.forEach((c) => c.clear());
      variacoes.clear();

      setState(() {
        tipoTamanho = 'numerico';
        possuiVariacoesCor = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao cadastrar produto: $e")),
      );
    }
  }

  void _gerarCamposTamanhosNumericos() {
    tamanhosNumericos.clear();
    final tamanhos = tamanhosNumericosController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    for (var tamanho in tamanhos) {
      tamanhosNumericos[tamanho] = TextEditingController();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cadastro de Produto',
              style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
          backgroundColor: Color.fromARGB(255, 216, 98, 13),
          iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        backgroundColor: const Color(0xFFFAF3E0),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(children: [
              TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 10),
              TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(labelText: 'Descrição')),
              const SizedBox(height: 10),
              TextField(
                controller: precoController,
                decoration: const InputDecoration(labelText: 'Preço'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),

              // Campo para adicionar URL da imagem
              TextField(
                controller: urlImagemController,
                decoration:
                    const InputDecoration(labelText: 'URL da Imagem'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final url = urlImagemController.text.trim();
                  if (url.isNotEmpty) {
                    setState(() {
                      urlsImagens.add(url);
                      urlImagemController.clear();
                    });
                  }
                },
                child: const Text('Adicionar Imagem por URL'),
              ),

              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: urlsImagens.map((url) {
                  final index = urlsImagens.indexOf(url);
                  return Stack(
                    children: [
                      Image.network(url,
                          width: 100, height: 100, fit: BoxFit.cover),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              urlsImagens.removeAt(index);
                            });
                          },
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
            
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _salvarProduto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 216, 98, 13),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cadastrar Produto',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (possuiVariacoesCor) ...[
                ElevatedButton(
                  onPressed: adicionarVariacao,
                  child: const Text('+ Adicionar Cor'),
                ),
                const SizedBox(height: 10),
                ...variacoes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final corData = entry.value;
                  final tamanhos =
                      corData['tamanhos'] as Map<String, TextEditingController>;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration:
                                      const InputDecoration(labelText: 'Cor'),
                                  onChanged: (value) {
                                    corData['cor'] = value.trim();
                                  },
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => removerVariacao(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Tamanhos e Estoque:'),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 10,
                            children: [
                              'P',
                              'M',
                              'G',
                              'GG',
                              '36',
                              '38',
                              '40',
                              '42'
                            ].map((tamanho) {
                              tamanhos.putIfAbsent(
                                  tamanho, () => TextEditingController());
                              return SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: tamanhos[tamanho],
                                  keyboardType: TextInputType.number,
                                  decoration:
                                      InputDecoration(labelText: tamanho),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ]
            ])));
  }
}
