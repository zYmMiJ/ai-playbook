# 02 - Découper

Trouver les plus petites tranches verticales utiles dans le périmètre confirmé.

## Entrée

Le périmètre de Story confirmé (action `cadrer`).

## Sortie

Une liste de candidats approuvée, avec leur valeur et leurs relations connues.

## Démarche

1. **Découper.** Appliquer [slicing](../references/slicing.md) au résultat utilisateur visé.
2. **Relier.** Appliquer [relations](../references/relations.md) pour les parents, dépendances et
   blocages déjà connus.
3. **Classer.** Retirer ou reclasser les découpages par couche technique, les résultats trop
   larges, et les questions non résolues.
4. **Confirmer.** Ne demander l'arbitrage de l'utilisateur que si des découpages alternatifs
   changent la valeur livrée ; sinon continuer.

## Vérification

| Cas | Attendu |
|---|---|
| Candidat | nomme un résultat observable pour l'utilisateur/la partie prenante |
| Mauvais découpage | une couche technique, un résultat trop large, ou un item purement exploratoire est reclassé |
| Relations | chaque relation connue et supportée est présente ; aucune n'est inventée |
| Source déjà complète | aucune dépendance ajoutée sauf si elle bloque réellement la livraison |
| Découpages alternatifs | aucune Story rédigée tant que l'utilisateur n'a pas choisi |
