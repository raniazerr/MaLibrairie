import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';

class DetailLivreScreen extends StatefulWidget {
  final Livre livre;

  const DetailLivreScreen({super.key, required this.livre});

  @override
  State<DetailLivreScreen> createState() => _DetailLivreScreenState();
}

class _DetailLivreScreenState extends State<DetailLivreScreen> {
  bool _suppressionEnCours = false;

  Future<void> _supprimerLivre() async {
    final confirmer = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce livre ?'),
        content: Text('Voulez-vous vraiment supprimer "${widget.livre.titre}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmer != true) return;

    setState(() => _suppressionEnCours = true);

    try {
      await FirebaseFirestore.instance
          .collection('Livres')
          .doc(widget.livre.id)
          .delete();

      if (mounted) {
        Navigator.pop(context); // retour au home_screen après suppression
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livre supprimé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _suppressionEnCours = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final livre = widget.livre;

    return Scaffold(
      appBar: AppBar(
        title: Text(livre.titre),
        actions: [
          IconButton(
            icon: _suppressionEnCours
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.delete),
            onPressed: _suppressionEnCours ? null : _supprimerLivre,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livre.image.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    livre.image,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 80, color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              livre.titre,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              livre.auteur,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(livre.statut)),
            const SizedBox(height: 16),
            Text(
              livre.resume,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}