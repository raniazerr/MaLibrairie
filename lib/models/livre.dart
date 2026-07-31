class Livre {
  final String id;
  final String titre;
  final String auteur;
  final String resume;
  final String image;
  final String statut;
  final String userId;

  Livre({
    required this.id,
    required this.titre,
    required this.auteur,
    required this.resume,
    required this.image,
    required this.statut,
    required this.userId,
  });

  factory Livre.fromFirestore(String id, Map<String, dynamic> data) {
    return Livre(
      id: id,
      titre: data['titre'] ?? '',
      auteur: data['auteur'] ?? '',
      resume: data['resume'] ?? '',
      image: data['image'] ?? '',
      statut: data['statut'] ?? 'a_lire',
      userId: data['userId'] ?? '',
    );
  }
}