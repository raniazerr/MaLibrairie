import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjouterLivreScreen extends StatefulWidget {
  const AjouterLivreScreen({super.key});

  @override
  State<AjouterLivreScreen> createState() => _AjouterLivreScreenState();
}

class _AjouterLivreScreenState extends State<AjouterLivreScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titreController = TextEditingController();
  final _auteurController = TextEditingController();
  final _resumeController = TextEditingController();
  final _imageController = TextEditingController();
  String _statut = 'a_lire';

  bool _enCours = false;

  Future<void> _ajouterLivre() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enCours = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      await FirebaseFirestore.instance.collection('Livres').add({
        'titre': _titreController.text,
        'auteur': _auteurController.text,
        'resume': _resumeController.text,
        'imageUrl': _imageController.text,
        'statut': _statut,
        'userId': userId,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _enCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un livre')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _auteurController,
                decoration: const InputDecoration(labelText: 'Auteur'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _resumeController,
                decoration: const InputDecoration(labelText: 'Résumé'),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL de la couverture',
                  hintText: 'https://...',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _statut,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'a_lire', child: Text('À lire')),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'lu', child: Text('Lu')),
                ],
                onChanged: (value) {
                  setState(() => _statut = value!);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _enCours ? null : _ajouterLivre,
                child: _enCours
                    ? const CircularProgressIndicator()
                    : const Text('Ajouter le livre'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}