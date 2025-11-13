import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaProduto extends StatelessWidget {
  final String idEstoque;
  final String nome;
  final double preco;
  final String descricao;
  final List<String> imagens;

  const TelaProduto({
    super.key,
    required this.idEstoque,
    required this.nome,
    required this.preco,
    required this.descricao,
    required this.imagens,
  });

  void _adicionarAoCarrinho(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Você precisa estar logado.")),
      );
      return;
    }

    try {
      final carrinhoRef = FirebaseFirestore.instance.collection('carrinho');

      final existing = await carrinhoRef
          .where('uid', isEqualTo: user.uid)
          .where('id', isEqualTo: idEstoque)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final docId = existing.docs.first.id;
        final currentQty = existing.docs.first['quantidade'] ?? 1;
        await carrinhoRef.doc(docId).update({'quantidade': currentQty + 1});
      } else {
        await carrinhoRef.add({
          'uid': user.uid,
          'id': idEstoque,
          'nome': nome,
          'imagem': imagens.isNotEmpty ? imagens.first : '',
          'preco': preco,
          'quantidade': 1,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produto adicionado ao carrinho!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao adicionar: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 216, 98, 13),
        title: Text(nome, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
         body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagem principal com sombra
            Container(
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageView.builder(
                  itemCount: imagens.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imagens[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image,
                              size: 100, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              nome,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${preco.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 22,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              descricao,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _adicionarAoCarrinho(context),
                icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFFAF3E0),),
                label: const Text("Adicionar ao Carrinho", style: TextStyle(color: Colors.white), ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 216, 98, 13),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
