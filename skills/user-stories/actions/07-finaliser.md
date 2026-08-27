# 07 - Finaliser

Approuver et persister les Stories, les transitionner, ou les garder en session sans écrire.

## Entrée

Les Stories, le changement demandé sur elles, et l'autorité pour ce changement.

## Sortie

Les brouillons de session, ou les identités de Story créées/mises à jour. Après une écriture,
rapporter chaque identité stable, les champs changés (`avant -> après`), les relations affectées,
et le résultat de la vérification. Pour un brouillon ou une absence d'écriture, dire explicitement
qu'aucun changement n'a été persisté.

## Démarche

1. **Résoudre.** Appliquer [persistence](../references/persistence.md) pour choisir le support et
   la route création/mise à jour.
2. **Statut.** Appliquer [lifecycle](../references/lifecycle.md) à chaque changement d'état
   demandé.
3. **Autoriser.** Confirmer l'approbation ou une autorité d'écriture bornée ; sinon renvoyer la
   proposition sans écrire.
4. **Relier.** Appliquer [relations](../references/relations.md).
5. **Écrire.** Créer ou mettre à jour seulement les Stories autorisées, en préservant les champs
   hors du changement autorisé.
6. **Vérifier.** Relire le graphe affecté et rapporter ce qui a changé.
7. **Rapporter.** Retourner chaque identité persistée, puis appliquer
   [handoffs](../references/handoffs.md) pour la suite.

## Vérification

| Cas | Attendu |
|---|---|
| Non autorisé | la Story et les artefacts liés restent inchangés |
| Transition seule | le statut change ; aucun nouveau brouillon créé |
| Parent | sa réévaluation est proposée, jamais déduite automatiquement |
| Pas de cible de persistance | aucune écriture ni rapport de statut ; la réponse se termine par une question (session ou Markdown) |
| Correspondance existante | identité et champs non autorisés préservés ; pas de doublon créé |
| Écriture approuvée | exactement une identité par Story ; chaque relation a un seul propriétaire, aucun champ inverse dupliqué |
| Markdown | un fichier par Story au chemin standard ; source et fichier parent inchangés sauf autorisation séparée |
| Changement de statut | la transition existe dans `lifecycle` ; `done` suppose l'acceptation validée et la Definition of Done du projet si elle existe |
