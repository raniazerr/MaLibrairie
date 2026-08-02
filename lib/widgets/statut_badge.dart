import 'package:flutter/material.dart';

String statutLisible(String statut) {
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

Color statutCouleur(String statut) {
  switch (statut) {
    case 'a_lire':
      return const Color(0xFFFFA726);
    case 'en_cours':
      return const Color(0xFF42A5F5);
    case 'lu':
      return const Color(0xFF66BB6A);
    default:
      return Colors.grey;
  }
}

class StatutBadge extends StatelessWidget {
  final String statut;
  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final couleur = statutCouleur(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statutLisible(statut),
        style: TextStyle(
          color: couleur,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}