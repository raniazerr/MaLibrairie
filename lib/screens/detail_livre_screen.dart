import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/livre.dart';
import '../widgets/statut_badge.dart';

class LivreDetailScreen extends StatefulWidget {
  final Livre livre;

  const LivreDetailScreen({super.key, required this.livre});

  @override
  State<LivreDetailScreen> createState() => _LivreDetailScreenState();
}

class _LivreDetailScreenState extends State<LivreDetailScreen> {
  late String _statutActuel;
  bool _suppressionEnCours = false;

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
          SnackBar(
            content: Text(
              'Statut mis à jour : ${statutLisible(nouveauStatut)}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _confirmerSuppression() async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce livre ?'),
        content: Text(
          'Cette action est définitive. "${widget.livre.titre}" sera retiré de ta bibliothèque.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      await _supprimerLivre();
    }
  }

  Future<void> _supprimerLivre() async {
    setState(() => _suppressionEnCours = true);

    try {
      await FirebaseFirestore.instance
          .collection('Livres')
          .doc(widget.livre.id)
          .delete();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
        setState(() => _suppressionEnCours = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final livre = widget.livre;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: _suppressionEnCours
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _suppressionEnCours ? null : _confirmerSuppression,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              child: livre.image.isNotEmpty
                  ? Image.network(
                      livre.image,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 280,
                        color: colors.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.book,
                          size: 72,
                          color: colors.primary,
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 280,
                      color: colors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.book, size: 72, color: colors.primary),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livre.titre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    livre.auteur,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Statut',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildStatutChip('a_lire', 'À lire'),
                      _buildStatutChip('en_cours', 'En cours'),
                      _buildStatutChip('lu', 'Lu'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Résumé',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    livre.resume,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                  ),
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
    final couleur = statutCouleur(valeur);
    return ChoiceChip(
      label: Text(label),
      selected: estSelectionne,
      onSelected: (selected) {
        if (selected) _changerStatut(valeur);
      },
      selectedColor: couleur.withValues(alpha: 0.18),
      labelStyle: TextStyle(
        color: estSelectionne ? couleur : Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}
