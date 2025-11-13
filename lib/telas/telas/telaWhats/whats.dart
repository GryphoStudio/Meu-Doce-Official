import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:myapp/main.dart';

void main() {
  runApp(const TelaComunic());
}

class TelaComunic extends StatelessWidget {
  const TelaComunic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contato',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.transparent,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const MyHomePage(
        title: '',
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required TextStyle style});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? latestWhatsAppLink;
  String? latestWhatsAppNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLatestWhatsAppLink();
  }

  // 🔹 Busca o link do Firestore
  Future<void> fetchLatestWhatsAppLink() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('whats')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          latestWhatsAppLink = snapshot.docs.first['link'] as String?;
          latestWhatsAppNumber = snapshot.docs.first['numero'] as String?;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar link do WhatsApp: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 🔹 Abre o WhatsApp com o link correto
  Future<void> _openWhatsAppLink() async {
    if (latestWhatsAppLink == null || latestWhatsAppLink!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link do WhatsApp indisponível.')),
      );
      return;
    }

    String url = latestWhatsAppLink!.trim();

    // Se o link não tiver https://, adiciona automaticamente
    if (!url.startsWith('http')) {
      url = 'https://wa.me/$url';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MyApp()),
          ),
          tooltip: 'Voltar',
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFa8e063), Color(0xFF56ab2f)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 12,
                      shadowColor: Colors.black54,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Fale com o vendedor",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                          
                            ElevatedButton.icon(
                              onPressed: _openWhatsAppLink,
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: Colors.white, size: 28),
                              label: const Text(
                                'Entre em contato via WhatsApp',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 28),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (latestWhatsAppNumber != null)
                              Column(
                                children: [
                                  const Text(
                                    'Ou envie uma mensagem para:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    latestWhatsAppNumber!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[900],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
