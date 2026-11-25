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
`en attente arbitrage <PREFIX>-<NUM>`).

> **À adapter par projet** en copiant ce skill : le format d'ID de ticket, la source (Jira/Linear/
> GitHub Issues...), et les "rappels transverses" en bas de fichier sont spécifiques à chaque repo.
> Ne pas copier ce fichier tel quel sans l'adapter — voir la section correspondante en bas.

**Phases et `/clear`** — les étapes ci-dessous se regroupent en 3 phases pour la gestion du
contexte (voir [`../../rules/context-efficiency.md`](../../rules/context-efficiency.md)) :
**Analyse** (1-4, jusqu'à la validation du plan), **Implémentation** (5-6), **Review** (7-8). Ce
qui doit survivre d'une phase à l'autre passe par `tickets/<ID>/analyse.md` et `plan.md`, pas par
l'historique de conversation — faire un `/clear` entre phases sur un ticket volumineux plutôt que
de laisser tout s'accumuler dans une seule session.

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
**Exploration minimale** : s'arrêter dès qu'il y a assez d'éléments pour écrire le plan — ne pas
lire tout un module/repo "pour être complet" quand le ticket ne touche qu'un fichier/une fonction.
Écrire `tickets/<ID>/analyse.md` : contexte, exploration, constats. **Ne pas écrire de code.**

## 3. Plan

Écrire `tickets/<ID>/plan.md` en suivant le
[gabarit](assets/plan-template.md) (contenu standardisé, pour retrouver la même structure d'un
ticket à l'autre) :
- **Statut** en première ligne (voir ci-dessus).
- **Changements fichier par fichier** — ce qui va changer, par fichier concerné.
- **Cas limites** identifiés.
- **Vérification** — la commande pass/fail (build, lint, tests ciblés existants, diff de sortie...)
  qui dira que l'implémentation est finie, et le résultat attendu (voir
  [`../../rules/verification.md`](../../rules/verification.md)).
- **Décisions** — toute décision d'architecture/design prise pendant l'analyse, même mineure. Pour
  **chacune**, proposer (ne pas écrire) où elle devrait être documentée une fois validée — voir
  [`../../rules/docs-structure.md`](../../rules/docs-structure.md) pour la convention
  `docs/decisions/` vs `docs/architecture/` vs `docs/modules/`.

## 4. Validation du plan

**Attendre la validation explicite de l'utilisateur** — sur le contenu technique du plan *et* sur
les propositions de doc de l'étape 3. Ne rien implémenter avant. Une fois validé : statut →
`validé`.

Proposer ensuite de démarrer l'implémentation dans une **session vierge** (`/clear`, ou l'option
d'approbation qui vide le contexte en plan mode) : `plan.md` est le relais, l'historique de
l'analyse n'a plus à être relu à chaque tour.

## 5. Implémentation

Implémenter en suivant les conventions du code environnant (voir le `CLAUDE.md` du projet). Statut
→ `en implémentation`.

L'implémentation n'est finie que quand la commande de la section **Vérification** du plan passe —
une commande qui s'appuie sur des tests **existants** (les nouveaux tests s'écrivent à l'étape 7).
Pendant l'itération, **uniquement des tests ciblés** (ceux qui couvrent les fichiers touchés),
**lancés en arrière-plan** ; jamais la suite complète à cette étape. Montrer la commande et sa
sortie, pas seulement « ça passe ».

## 6. Fin d'implémentation — STOP

Une fois le code écrit, **ne rien enchaîner automatiquement**. Présenter ce qui a été fait et
demander explicitement une confirmation que l'implémentation est bonne. **Ne pas écrire de nouveaux
tests, ne pas lancer la suite complète, ne pas toucher à la doc** tant que ce n'est pas confirmé —
seuls les tests ciblés de l'étape 5 ont tourné.

## 7. Après validation de l'implémentation

a. Écrire/compléter les tests. **Tests ciblés avant tests complets** : lancer d'abord ceux qui
   couvrent les fichiers modifiés, réserver la suite complète à la validation finale de cette
   étape.
b. Appliquer les mises à jour de doc **validées** à l'étape 3 — cette fois les écrire réellement.
c. Faire relire le diff contre `plan.md` par un relecteur en contexte vierge (agent
   [`plan-compliance-reviewer`](../../agents/plan-compliance-reviewer.md), ou `/code-review`) : seuls
   les écarts de correction ou d'exigences comptent, pas le style. Corriger ou signaler chaque
   écart.
d. Proposer un message de commit référençant l'ID du ticket (voir le skill
   [`writing-good-commits`](../writing-good-commits/SKILL.md)) — ne pas committer soi-même sauf
   demande explicite pour ce tour.

## 8. Clôture

Statut en tête de `tickets/<ID>/plan.md` → `implémenté`.

## Rappels transverses (à compléter par projet)

Section à personnaliser à chaque copie avec les pièges/règles propres au repo — ce que le
`CLAUDE.md` du projet documente déjà comme piège récurrent mérite un rappel ici. Un seul rappel
reste valable partout et peut rester tel quel :

- Jamais de commit sans demande explicite pour ce tour précis.
