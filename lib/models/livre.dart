class Livre {
  final String id;
  final String titre;
  final String auteur;
  final String resume;
  final String imageUrl;
  final String statut;
  final String userId;

  Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.resume,
    required this.imageUrl,
    required this.statut,
    required this.userId,
  });

  factory Livre.fromFirestore(String id, Map<String, dynamic> data) {
    return Livre(
      id: id,
      titre: data['titre'] ?? '',
      auteur: data['auteur'] ?? '',
      resume: data['resume'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      statut: data['statut'] ?? 'a_lire',
      userId: data['userId'] ?? '',
    );
  }
}