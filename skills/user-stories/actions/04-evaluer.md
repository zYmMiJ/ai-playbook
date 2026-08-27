# 04 - Évaluer

Déterminer la maturité et les blocages de chaque Story.

## Entrée

Les brouillons de Story.

## Sortie

Les documents de Story avec leur statut, et un Spike proposé pour toute inconnue bloquante (voir
la note d'adaptation du `SKILL.md` : proposé sous forme de signalement, pas de skill `spike` dédié
ici).

## Démarche

1. **Qualité.** Appliquer [readiness](../references/readiness.md) à chaque Story.
2. **Inconnues.** Appliquer [handoffs](../references/handoffs.md) et
   [relations](../references/relations.md).
3. **Reformer.** Renvoyer à l'action `decouper` toute Story trop grosse ou sans valeur propre.
4. **Statut.** N'utiliser `ready` que si tous les critères de maturité passent. Sinon garder
   `proposed` et ne lister que les critères en échec.
5. **Feedback.** Montrer les Stories changées ou encore `proposed`, demander sur le plus gros
   écart ; sinon continuer.

## Vérification

| Cas | Attendu |
|---|---|
| Ready | chaque critère passe ; aucun blocage restant à montrer |
| Proposed | chaque critère en échec correspond à un écart sourcé |
| Blocage non approuvé | la Story reste ; un Spike est proposé ; les autres artefacts liés restent inchangés |
| Blocage approuvé | le Spike nomme la Story en `parents` ; aucun champ inverse n'est dupliqué |
| Ensemble déjà ready et inchangé | aucune sortie intermédiaire |
| Sortie | pas de résumé d'évaluation générique, de champ vide, ou de rapport d'étape sautée |
