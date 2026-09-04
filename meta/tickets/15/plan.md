Statut : implémenté

## Objectif de l'US

Ajouter un workflow GitHub Actions déclenchable manuellement qui utilise Codex, en lecture seule,
pour générer un brouillon de release notes à partir de l'historique Git, livré comme artifact.

## Challenge de l'architecture (avant implémentation)

Relecture de `analyse.md` avant de coder, sur les points demandés explicitement :

- **Sur-architecture ?** Non : 1 workflow, 1 fichier de prompt statique, 1 `AGENTS.md`. Pas de
  script wrapper (Node/Python), pas de SDK, pas de job supplémentaire (pas de job de notification,
  pas de job de validation séparé) — l'action officielle fait tout ce qu'il faut en un step.
- **Duplication avec Claude ?** Non : `skills/generate-release-note` reste le mécanisme humain
  validé qui écrit dans `docs/releases/`. Ce workflow écrit un artifact CI séparé
  (`release-notes.md`), jamais dans `docs/releases/`. Les deux peuvent coexister sans se marcher
  dessus ; à fusionner plus tard seulement si l'usage prouve que le brouillon Codex est fiable.
- **Codex reste limité aux automatisations ?** Oui : `AGENTS.md` le dit explicitement, le workflow
  ne peut être déclenché que manuellement, `permission-profile: ':read-only'` interdit toute
  mutation du filesystem par Codex lui-même (le fichier de sortie est écrit par l'action, pas par
  Codex).
- **Permissions minimales ?** Oui : `permissions: contents: read` au niveau workflow, pas de
  `pull-requests`/`issues`/`actions: write`. Le secret OpenAI est scoping projet dédié (voir
  `analyse.md`).
- **Une étape nécessite-t-elle une écriture sur le repository ?** Non : `release-notes.md` est écrit
  dans le workspace éphémère du runner puis uploadé en artifact — jamais commité, jamais poussé.
  `.gitignore` complété pour ces deux fichiers de travail éphémères par prudence (au cas où
  quelqu'un lance les commandes en local), mais aucun step du workflow ne fait de `git add`/`commit`.

Conclusion : l'architecture d'`analyse.md` est retenue telle quelle, sans simplification ni
complexification supplémentaire.

## Critères d'acceptation

- [x] Un workflow GitHub Actions peut être lancé manuellement (`workflow_dispatch`).
- [x] Il utilise Codex (`openai/codex-action@v1`, `codex exec` en interne).
- [x] Aucune clé n'est stockée dans Git (uniquement `${{ secrets.OPENAI_API_KEY }}`).
- [x] Les permissions GitHub sont minimales (`contents: read`, rien d'autre).
- [x] Le résultat est généré en Markdown (`release-notes.md`).
- [x] Le résultat est disponible comme artifact GitHub Actions (`actions/upload-artifact`).
- [x] Codex ne peut pas pousser ou merger (`permission-profile: ':read-only'`, pas de step git
      push/commit dans le workflow).
- [x] Les release notes utilisent uniquement des informations vérifiables (`git log` de la plage
      demandée, injecté dans le prompt — pas d'accès réseau/web depuis le sandbox Codex).
- [x] La documentation explique le setup complet (`README.md` section "OpenAI Codex setup").

## Changements fichier par fichier

- `tickets/15/analyse.md` — analyse complète (contexte, problème, solutions Codex comparées,
  authentification, architecture, risques, décision).
- `tickets/15/plan.md` — ce fichier.
- `AGENTS.md` (racine) — instructions minimales pour Codex : rôle (automatisation uniquement),
  sources de vérité, interdictions (inventer, sortir du scope, modifier le repo arbitrairement).
- `automation/release-notes/prompt.md` — règles statiques de génération des release notes (partie
  invariante du prompt ; le contexte Git variable est concaténé à l'exécution par le workflow).
- `.github/workflows/codex-release-notes.yml` — le workflow : `workflow_dispatch` (inputs
  `from_ref`/`to_ref`), checkout complet, résolution de la plage, construction du contexte Git,
  assemblage du prompt, appel `openai/codex-action@v1`, upload artifact.
- `README.md` — section "AI tools" (Claude Code vs Codex) + section "OpenAI Codex setup" (étapes
  manuelles OpenAI/GitHub, procédure de test, coûts).
- `.gitignore` — ajoute les deux fichiers de travail éphémères du workflow (`release-notes.md` à la
  racine, `.codex-prompt.md`), par prudence si quelqu'un rejoue les commandes en local.

## Cas limites

- **`from_ref` non fourni et aucun tag existant avant `to_ref`** — le workflow échoue explicitement
  (`::error::` + `exit 1`) plutôt que de deviner une plage ou de prendre tout l'historique par
  défaut (risquerait un prompt énorme et une génération peu pertinente).
- **`to_ref`/`from_ref` invalide** (ref qui n'existe pas) — `git rev-parse --verify` échoue tôt,
  message d'erreur clair du runner plutôt qu'un `git log` silencieusement vide.
- **Plage vide** (`from_ref` == `to_ref`, ou aucun commit non-merge entre les deux) — le `git log`
  produit une liste vide ; le prompt (`automation/release-notes/prompt.md`) demande explicitement de
  ne rien inventer dans ce cas, Codex devrait renvoyer un résultat indiquant l'absence de changement
  plutôt qu'un contenu halluciné. Non testé en conditions réelles à ce stade (voir Definition of
  Done / tests manuels).
- **Un seul tag existe sur ce repo (`0.1.0`, confondu avec `HEAD` actuel)** — documenté dans le
  README comme cas de test à l'aide d'un ancien commit en guise de `from_ref` plutôt qu'un tag,
  faute d'un deuxième tag disponible pour un test de bout en bout réaliste.
- **`OPENAI_API_KEY` absent/invalide** — l'action Codex échoue avec son propre message d'erreur ;
  pas de mitigation supplémentaire côté workflow, comportement natif de l'action jugé suffisant pour
  ce MVP.

## Décisions

- **Ne pas écrire dans `docs/releases/`** depuis ce workflow (artifact séparé plutôt que fusion avec
  le mécanisme `generate-release-note` existant) — proposé pour : rester tel quel, documenté dans
  `analyse.md` (section Architecture) ; à promouvoir en doc `docs/decisions/` seulement si une V2
  fait effectivement converger les deux mécanismes (pas de doc séparée créée pour ce MVP, l'analyse
  du ticket fait déjà office de trace de la décision).
- **`permission-profile: ':read-only'` plutôt que `':workspace'`** — proposé pour : idem, resterait
  dans `analyse.md`/ce plan tant qu'aucun futur workflow Codex n'a besoin d'écrire dans le repo (le
  jour où un cas d'usage l'exige, ce sera l'occasion d'un vrai document `docs/decisions/` sur
  l'élargissement des droits Codex, pas avant).
- **`AGENTS.md` à la racine, en anglais, minimal** — proposé pour : rester tel quel ; il ne
  documente pas d'architecture (pas matière à `docs/architecture/`), n'est pas un choix ponctuel
  rattaché à une question technique isolée (pas un candidat `docs/decisions/`) — c'est un fichier de
  configuration d'outil, comme `.claude/settings.json`, pas un document `docs/`.

## Fichiers prévus

Voir "Changements fichier par fichier" ci-dessus — liste stable entre plan et implémentation,
aucun fichier supplémentaire ajouté en cours de route.

## Étapes

1. Créer l'US — [issue #15](https://github.com/zYmMiJ/ai-playbook/issues/15) +
   `tickets/15/analyse.md`/`plan.md` — fait.
2. Créer `AGENTS.md` — fait.
3. Créer le prompt statique de release notes (`automation/release-notes/prompt.md`) — fait.
4. Créer le workflow GitHub Actions (`.github/workflows/codex-release-notes.yml`) — fait.
5. Documenter l'authentification et l'utilisation dans `README.md` — fait.
6. Valider la syntaxe YAML et relire la checklist sécurité (secret, permissions, sandbox) — fait
   (voir rapport donné à l'utilisateur avec l'implémentation).
7. Tester le workflow — **non fait** : nécessite le secret `OPENAI_API_KEY` configuré sur le repo
   GitHub par l'utilisateur (étape manuelle, hors périmètre de ce que Claude peut faire). Procédure
   de test documentée dans le README pour que l'utilisateur la déclenche lui-même.

## Definition of Done

- [x] Les 5 fichiers listés existent et le YAML est syntaxiquement valide.
- [x] Aucune clé/valeur d'exemple de clé n'apparaît en clair dans le repo.
- [x] `permissions:` du workflow limité à `contents: read`.
- [x] `README.md` permet à quelqu'un n'ayant jamais utilisé Codex de configurer le secret et de
      déclencher le workflow sans aide supplémentaire.
- [ ] Le workflow a été exécuté au moins une fois avec succès sur GitHub — **à faire par
      l'utilisateur** (nécessite la création du secret `OPENAI_API_KEY`, étape humaine volontaire,
      voir README). Statut du ticket restera "implémenté" (le code est livré et jugé complet) même
      si ce dernier point reste à vérifier en conditions réelles par l'utilisateur.
