# 06 - Ordonner

Ordonner les Stories qui partagent un même parent, sans inventer de priorité.

## Entrée

Les Stories évaluées et les éléments produit disponibles.

## Sortie

Un ordre relatif approuvé.

## Démarche

1. **Comparer.** Appliquer [ordering](../references/ordering.md).
2. **Séquencer.** Appliquer [relations](../references/relations.md) pour les prédécesseurs et
   blocages.
3. **Expliquer.** Donner la preuve derrière chaque position proposée et chaque arbitrage.
4. **Décider.** Laisser l'utilisateur (ou l'autorité que l'appelant a explicitement donnée)
   changer ou approuver l'ordre.
5. **Enregistrer.** Ne stocker que l'ordre relatif approuvé.

## Vérification

| Cas | Attendu |
|---|---|
| Pas de concurrence entre Stories | action sautée ; aucun champ d'ordre ajouté |
| Ensemble ordonné | chaque Story a une position unique appuyée par un signal de la source ou une relation |
| Blocage | le bloquant précède l'item qu'il bloque |
| Signal non appuyé | aucun score, priorité, ou poids d'ordonnancement ajouté sans preuve |
