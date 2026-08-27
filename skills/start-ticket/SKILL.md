---
name: start-ticket
description: >
  Traite un ticket (Jira ou autre tracker) collé dans la conversation de bout en bout — analyse du
  code, plan de changements, implémentation, tests, doc. Se déclenche quand l'utilisateur colle le
  contenu ou l'URL d'un ticket, ou demande de "traiter un ticket", "analyser un ticket", "commencer
  un ticket", "reprendre le ticket X".
---

# Traiter un ticket

Structure cible : `tickets/<ID>/analyse.md` (exploration, sans code écrit) + `tickets/<ID>/plan.md`
(changements fichier par fichier, cas limites, section "Décisions", statut en tête de fichier).

**Statut** — une des 4 valeurs `à valider` / `validé` / `en implémentation` / `implémenté`, ou une
raison de blocage explicite si le ticket est en attente d'un tiers (ex. `en attente maquette`,
`en attente arbitrage RUE-XXX`).

> **À adapter par projet** en copiant ce skill : le format d'ID de ticket, la source (Jira/Linear/
> GitHub Issues...), et les "rappels transverses" en bas de fichier sont spécifiques à chaque repo.
> Ne pas copier ce fichier tel quel sans l'adapter — voir la section correspondante en bas.

## 1. Identifier le ticket

Extraire l'ID du texte/URL collé (adapter le pattern au tracker utilisé, ex. `[A-Z]{2,}-\d+` pour
Jira).

**Si l'utilisateur ne fournit que l'ID** (pas de contenu collé) : essayer de le récupérer
directement depuis le tracker plutôt que de demander un copier-coller (voir un éventuel skill de
connexion au tracker du projet). Si la config est absente ou la requête échoue : basculer sans
bloquer sur le mode manuel (demander à l'utilisateur de coller le contenu).

- `tickets/<ID>/` existe déjà → l'ouvrir, lire `plan.md`. **Ne jamais faire confiance au statut
  affiché sans vérifier** : chercher dans le code/git les éléments concrets que le plan prétend
  avoir livrés (`git log --all --grep="<ID>"`, `grep` des noms cités) avant de continuer. Un plan
  marqué "implémenté" peut décrire du travail perdu faute de commit. Si divergence entre le plan et
  le code réel : la signaler à l'utilisateur avant de continuer, ne pas trancher seul.
- Sinon → créer `tickets/<ID>/`.

## 2. Analyse

Explorer le code concerné (fichiers/composants/classes, endpoints ou tables existants pertinents).
Écrire `tickets/<ID>/analyse.md` : contexte, exploration, constats. **Ne pas écrire de code.**

## 3. Plan

Écrire `tickets/<ID>/plan.md` :
- **Statut** en première ligne (voir ci-dessus).
- **Changements fichier par fichier** — ce qui va changer, par fichier concerné.
- **Cas limites** identifiés.
- **Décisions** — toute décision d'architecture/design prise pendant l'analyse, même mineure. Pour
  **chacune**, proposer (ne pas écrire) où elle devrait être documentée une fois validée — voir
  [`../../rules/docs-structure.md`](../../rules/docs-structure.md) pour la convention
  `docs/decisions/` vs `docs/architecture/` vs `docs/modules/`.

## 4. Validation du plan

**Attendre la validation explicite de l'utilisateur** — sur le contenu technique du plan *et* sur
les propositions de doc de l'étape 3. Ne rien implémenter avant. Une fois validé : statut →
`validé`.

## 5. Implémentation

Implémenter en suivant les conventions du code environnant (voir le `CLAUDE.md` du projet). Statut
→ `en implémentation`.

## 6. Fin d'implémentation — STOP

Une fois le code écrit, **ne rien enchaîner automatiquement**. Présenter ce qui a été fait et
demander explicitement une confirmation que l'implémentation est bonne. **Ne pas lancer les tests,
ne pas toucher à la doc** tant que ce n'est pas confirmé.

## 7. Après validation de l'implémentation

a. Écrire/compléter les tests, les lancer.
b. Appliquer les mises à jour de doc **validées** à l'étape 3 — cette fois les écrire réellement.
c. Proposer un message de commit référençant l'ID du ticket (voir le skill
   [`writing-good-commits`](../writing-good-commits/SKILL.md)) — ne pas committer soi-même sauf
   demande explicite pour ce tour.

## 8. Clôture

Statut en tête de `tickets/<ID>/plan.md` → `implémenté`.

## Rappels transverses (à compléter par projet)

Section à personnaliser à chaque copie avec les pièges/règles propres au repo — ce que le
`CLAUDE.md` du projet documente déjà comme piège récurrent mérite un rappel ici. Un seul rappel
reste valable partout et peut rester tel quel :

- Jamais de commit sans demande explicite pour ce tour précis.
