import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import '../constants.dart';

/// Page pour afficher toutes les recettes d'une catégorie spécifique
/// Cette page est appelée quand on clique sur "View all"
class ViewAllItems extends StatefulWidget {
  // Le titre de la catégorie (ex: "Popular Recipes", "Breakfast", etc.)
  final String categoryTitle;

  // Le nom de la catégorie dans Firestore (peut être différent du titre affiché)
  final String? categoryName;

  const ViewAllItems({Key? key, required this.categoryTitle, this.categoryName})
    : super(key: key);

  @override
  State<ViewAllItems> createState() => _ViewAllItemsState();
}

class _ViewAllItemsState extends State<ViewAllItems> {
  // Instance Firestore pour récupérer les données
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar avec bouton retour et titre
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Bouton de notification (facultatif)
          IconButton(
            onPressed: () {},
            icon: const Icon(Iconsax.notification, color: Colors.black),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: StreamBuilder<QuerySnapshot>(
            // Stream qui écoute les changements dans Firestore
            // Si categoryName est fourni, on filtre par catégorie
            // Sinon, on affiche toutes les recettes
            stream: widget.categoryName != null
                ? _firestore
                      .collection('details')
                      // we can also use orderBy if needed here to sort the results
                      .where('category', isEqualTo: widget.categoryName)
                      .snapshots()
                : _firestore.collection('details').snapshots(),

            builder: (context, snapshot) {
              // ÉTAPE 1 : Gestion des erreurs
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              }

              // ÉTAPE 2 : Affichage du chargement
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: kprimaryColor),
                );
              }

              // ÉTAPE 3 : Vérifier si la liste est vide
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Iconsax.box, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune recette disponible',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // ÉTAPE 4 : Affichage des recettes dans un GridView
              return GridView.builder(
                // Configuration de la grille
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colonnes
                  crossAxisSpacing: 10, // Espacement horizontal
                  mainAxisSpacing: 10, // Espacement vertical
                  childAspectRatio: 0.8, // Ratio hauteur/largeur des items
                ),

                // Nombre d'items à afficher
                itemCount: snapshot.data!.docs.length,

                // Construction de chaque item
                itemBuilder: (context, index) {
                  // Récupération du document à l'index actuel
                  final recipe = snapshot.data!.docs[index];

                  // Extraction des données avec valeurs par défaut si null
                  final img = (recipe['image'] ?? '').toString();
                  final name = (recipe['name'] ?? 'Sans nom').toString();
                  final time = (recipe['time'] ?? '').toString();
                  final cal = (recipe['cal'] ?? '0').toString();

                  // Construction de la carte de recette
                  return RecipeCard(
                    image: img,
                    name: name,
                    time: time,
                    calories: cal,
                    onTap: () {
                      // TODO: Navigation vers les détails de la recette
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => RecipeDetailsPage(recipe: recipe),
                      //   ),
                      // );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget réutilisable pour afficher une carte de recette
/// Ce widget est séparé pour améliorer la lisibilité et la réutilisabilité
class RecipeCard extends StatelessWidget {
  final String image;
  final String name;
  final String time;
  final String calories;
  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.image,
    required this.name,
    required this.time,
    required this.calories,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PARTIE 1 : Image de la recette avec bouton favori
            Expanded(
              child: Stack(
                children: [
                  // Image de la recette
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            // Gestion de l'erreur de chargement
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 50,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.restaurant,
                                size: 50,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                  ),

                  // Bouton favori en haut à droite
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Icon(
                        Iconsax.heart,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PARTIE 2 : Informations de la recette
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de la recette
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Temps et calories
                  Row(
                    children: [
                      // Icône et temps
                      Icon(Iconsax.clock, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        time.isNotEmpty ? "$time Min" : "- Min",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(width: 10),

                      // Icône et calories
                      Icon(Iconsax.flash_1, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        "$calories Cal",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

