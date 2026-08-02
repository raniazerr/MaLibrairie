import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/theme_service.dart';
import '../models/livre.dart';
import 'ajouter_livre_screen.dart';
import 'detail_livre_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, _) {
            return IconButton(
              icon: Icon(mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
              onPressed: toggleTheme,
            );
          },
        ),
        title: const Text('MaBibliothèque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Livre>>(
        stream: FirestoreService().getLivres(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun livre trouvé'));
          }

          final livres = snapshot.data!;
          return ListView.builder(
            itemCount: livres.length,
            itemBuilder: (context, index) {
              final livre = livres[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: livre.image.isNotEmpty
    ? SizedBox(
        width: 50,
        height: 50,
        child: Image.network(
          livre.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Tooltip(
              message: error.toString(),
              child: const Icon(Icons.error, color: Colors.red, size: 40),
            );
          },
        ),
      )
    : const Icon(Icons.book, size: 40),
                  title: Text(livre.titre),
                  subtitle: Text('${livre.auteur} • ${livre.statut}'),
                  onTap: () {                
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailLivreScreen(livre: livre)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjouterLivreScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}