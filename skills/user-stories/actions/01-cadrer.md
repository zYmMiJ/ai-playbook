# 01 - Cadrer

Résoudre la source et borner un seul lot de User Stories.

## Entrée

Un Epic, un Product Brief, un PRD, une demande bornée, des Stories existantes, ou le contexte de
la conversation en cours.

## Sortie

Un périmètre de Story confirmé, avec sa source et son Epic parent éventuel.

## Démarche

1. **Résoudre.** Examiner la source fournie, les artefacts projet pertinents (docs, tickets déjà
   existants), et les items de backlog correspondants. Ne demander le besoin explicitement que si
   rien ne peut être résolu depuis ce qui est disponible.
2. **Qualifier.** Appliquer [qualification](../references/qualification.md). En cas de décalage
   (ce n'est pas de la valeur utilisateur indépendante), appliquer
   [handoffs](../references/handoffs.md).
3. **Borner.** Ne garder que ce qui vient de la source : acteur, besoin, résultat, limites, source,
   parent éventuel.
4. **Confirmer.** Poser une seule question et attendre la réponse quand une valeur manquante
   pourrait changer la Story.

## Vérification

| Cas | Attendu |
|---|---|
| Pas de source | aucun candidat ; une question ouverte sur le besoin |
| Résultat manquant | aucun candidat ; une question ouverte sur la valeur pour l'utilisateur/partie prenante |
| Autre type de travail | pas de candidat Story ; la capacité correspondante signalée à la place |
| Périmètre valide | un résultat, des limites explicites, une source identifiée, un parent confirmé s'il existe |
