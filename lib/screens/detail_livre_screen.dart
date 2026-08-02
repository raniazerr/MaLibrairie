import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';

class LivreDetailScreen extends StatefulWidget {
  final Livre livre;

  const LivreDetailScreen({super.key, required this.livre});

  @override
  State<LivreDetailScreen> createState() => _LivreDetailScreenState();
}

class _LivreDetailScreenState extends State<LivreDetailScreen> {
  late String _statutActuel;

  @override
  void initState() {
    super.initState();
    _statutActuel = widget.livre.statut;
  }

  Future<void> _changerStatut(String nouveauStatut) async {
    setState(() => _statutActuel = nouveauStatut);

    try {
      await FirebaseFirestore.instance
          .collection('Livres')
          .doc(widget.livre.id)
          .update({'statut': nouveauStatut});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Statut mis à jour : ${_statutLisible(nouveauStatut)}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  String _statutLisible(String statut) {
    switch (statut) {
      case 'a_lire':
        return 'À lire';
      case 'en_cours':
        return 'En cours';
      case 'lu':
        return 'Lu';
      default:
        return statut;
    }
  }

  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'a_lire':
        return Colors.orange[100]!;
      case 'en_cours':
        return Colors.blue[100]!;
      case 'lu':
        return Colors.green[100]!;
      default:
        return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final livre = widget.livre;

    return Scaffold(
      appBar: AppBar(title: Text(livre.titre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livre.image.isNotEmpty)
              Image.network(
                livre.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 80),
                ),
              )
            else
              Container(
                height: 300,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 80),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livre.titre,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    livre.auteur,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600], fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Sélecteur de statut
                  const Text('Statut', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatutChip('a_lire', 'À lire'),
                      _buildStatutChip('en_cours', 'En cours'),
                      _buildStatutChip('lu', 'Lu'),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text('Résumé', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(livre.resume, style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatutChip(String valeur, String label) {
    final estSelectionne = _statutActuel == valeur;
    return ChoiceChip(
      label: Text(label),
      selected: estSelectionne,
      selectedColor: _couleurStatut(valeur),
      onSelected: (selected) {
        if (selected) _changerStatut(valeur);
      },
    );
  }
}