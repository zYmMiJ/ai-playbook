# 03 - Rédiger

Rédiger chaque candidat approuvé comme une User Story testable.

## Entrée

La liste de candidats approuvée.

## Sortie

Un brouillon de Story par candidat.

## Démarche

1. **Énoncer.** Remplir le [gabarit User Story](../assets/user-story-template.md) avec l'acteur,
   le besoin, le résultat.
2. **Accepter.** Ajouter des conditions observables sourcées depuis la demande/le contexte.
   Demander ou omettre un comportement inconnu ; n'utiliser des exemples ou du Gherkin que si ça
   clarifie vraiment, pas par défaut.
3. **Relier.** Ajouter les métadonnées connues depuis [relations](../references/relations.md).
4. **Nettoyer.** Retirer les placeholders et les sections optionnelles vides.
5. **Feedback.** Montrer l'ensemble complet des Stories, demander ce qui doit changer, intégrer
   les corrections.

## Vérification

| Cas | Attendu |
|---|---|
| Nombre | exactement une Story par candidat approuvé |
| Structure | acteur, besoin, résultat, et au moins une condition d'acceptation observable |
| Traçabilité | acteur, besoin, résultat et acceptation viennent de la source ou d'une décision confirmée |
| Acceptation | ne contient que du comportement produit ; les relations de backlog restent en métadonnée |
| Métadonnée de source | absente sauf si appuyée par un id stable, une URL, ou un chemin relatif au projet |
| Feedback | ensemble complet montré ; aucune écriture sur disque à ce stade ; réponse terminée par une question ouverte |
