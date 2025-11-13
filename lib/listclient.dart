import 'package:flutter/material.dart';
import 'package:myapp/telas/telas/carrinho/carrinho.dart';
import 'package:myapp/telas/telas/notifica%C3%A7%C3%A3oGrid.dart';
import 'package:myapp/telas/telas/perfilUsuario/usuario.dart';



List<Widget> getClientDrawerItems(BuildContext context) {
  return [
    ListTile(
      leading: const Icon(Icons.notifications, color: Color(0xFF4E342E)),
      title: const Text('Notificações'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaGridNotificacoes()),
        );
      },
    ),
    ListTile(
      leading: const Icon(Icons.shopping_cart, color: Color(0xFF4E342E)),
      title: const Text('Carrinho'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CarrinhoMLApp()));
      },
    ),
    ListTile(
      leading: const Icon(Icons.person, color: Color(0xFF4E342E)),
      title: const Text('Minha conta'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => TelaUsuario()));
      },
    ),
  ];
}
//