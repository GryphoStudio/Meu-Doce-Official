import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/telas/telaProdutos/produtos.dart';

class ProdutosGrid extends StatelessWidget {
  final String searchQuery;

  const ProdutosGrid({super.key, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('estoque').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }

        final produtos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nome = (data['nome'] ?? '').toString().toLowerCase();
          final correspondeBusca = searchQuery.isEmpty ||
              nome.contains(searchQuery.toLowerCase());
          return correspondeBusca;
        }).toList();

        if (produtos.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 25,
            crossAxisSpacing: 15,
            childAspectRatio: 0.6,
          ),
          itemCount: produtos.length,
          itemBuilder: (context, index) {
            final produtoDoc = produtos[index];
            final produto = produtoDoc.data() as Map<String, dynamic>;
            final idEstoque = produtoDoc.id;

            final nome = produto['nome'] ?? 'Sem nome';
            final preco = (produto['preco'] ?? 0).toDouble();
            final descricao = produto['descricao'] ?? '';
            final imagensList = produto['imagens'] as List<dynamic>?;
            final imagens = imagensList != null
                ? imagensList.map((e) => e.toString()).toList()
                : <String>[];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaProduto(
                      idEstoque: idEstoque,
                      nome: nome,
                      preco: preco,
                      descricao: descricao,
                      imagens: imagens,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imagens.isNotEmpty
                                ? imagens[0]
                                : 'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 4),
                      child: Text(
                        'R\$ ${preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
