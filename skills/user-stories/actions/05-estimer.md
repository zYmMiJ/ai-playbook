# 05 - Estimer

Estimer les Stories seulement si demandé ou si le projet l'exige.

## Entrée

Les Stories évaluées et la convention d'estimation du projet (`CLAUDE.md`, si elle existe).

## Sortie

Des estimations confirmées, ou les Stories inchangées.

## Démarche

1. **Chiffrer.** Appliquer [estimation](../references/estimation.md).
2. **Proposer.** Expliquer la preuve derrière chaque estimation (comparaison avec un travail déjà
   fait de taille connue, avis de l'équipe...).
3. **Confirmer.** N'enregistrer que les estimations confirmées par l'utilisateur ou l'équipe.

## Vérification

| Cas | Attendu |
|---|---|
| Pas d'échelle définie par le projet | action sautée ; aucun champ d'estimation ajouté |
| Preuve insuffisante | aucune estimation sauf si l'utilisateur/l'équipe en fournit une |
| Estimation confirmée | l'échelle du projet est utilisée et une preuve comparable ou l'avis de l'équipe est nommé |
