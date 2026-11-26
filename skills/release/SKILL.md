---
name: release
description: >
  Sort une release via tag Git (calcul du tag, garde-fous, tag + push, release GitHub) — affiche les commandes
  exactes et ne les exécute qu'après permission explicite de l'utilisateur. Se déclenche pour "sortir une release", "déployer en prod",
  "tagger une version", "quel est le prochain tag", "pourquoi <env> est en retard sur <env>",
  "relancer une release".
---

# Release via tag Git

> **À adapter par projet** en copiant ce skill : le fichier qui porte le numéro de version
> (`pom.xml`, `package.json`, `VERSION`, `Cargo.toml`...), le nombre et les noms des environnements,
> le nom des workflows CI déclenchés, et l'éventuelle commande de redéploiement manuel côté hôte
> sont spécifiques à chaque repo. Un exemple d'instanciation générique (backend Spring Boot/Maven)
> est donné en bas de fichier — à ne pas copier tel quel, juste pour illustrer le niveau de détail
> attendu une fois adapté.

> Si le projet suit le modèle [Git Flow](../../rules/git-flow.md) (branches `main`/`develop`,
> `release/*`/`hotfix/*`), ce skill correspond à l'étape "tag + push" des actions
> [`git-flow`](../git-flow/SKILL.md) `release`/`hotfix` — son étape 0 "déterminer le tag" ci-dessous
> ne s'applique alors pas, la version étant déjà fixée avant le tag.

## Principe général

Deux logiques de déploiement distinctes, à ne pas confondre :

| Type | Déclencheur | Code livré |
|---|---|---|
| **Déploiement continu** (souvent un seul env, ex. qualif/staging/dev) | push sur la branche par défaut (= merge de PR) | HEAD de la branche |
| **Release** (souvent plusieurs env, ex. demo/prod) | push d'un **tag Git** | dernier commit **taggé**, jamais la HEAD non taggée |

Conséquence directe de cette convention : les environnements de release sont **toujours en retard**
sur la branche par défaut tant qu'aucun tag n'a été poussé — c'est attendu, pas un bug. **Un écart
de comportement entre l'environnement continu et un environnement de release est un écart de
version d'image/artefact, jamais un écart de config** (si les deux environnements lisent la même
config via variables d'environnement) : si un comportement diffère, chercher un commit pas encore
releasé plutôt qu'une différence de paramétrage.

## Environnement continu — rien à taper

Merger la PR vers la branche par défaut suffit ; le pipeline CI fait le reste. Rien de ce skill ne
s'applique à ce chemin.

## Release — déterminer le tag, tag + push, release GitHub

### 0. Déterminer le tag

La version du prochain tag est celle déjà présente dans le fichier de version sur la branche par
défaut, **sans** son éventuel suffixe de pré-release (`-rc.N`, `-SNAPSHOT`, `-beta.N`...) — ce
suffixe est en général fixé automatiquement à chaque merge par un commit dédié de bump de version.

```bash
git checkout <branche-par-défaut> && git pull
# lire la version courante dans le fichier de version du projet (pom.xml, package.json, VERSION...)
```

Retirer le suffixe de pré-release donne le tag à sortir. Vérifier qu'il n'existe pas déjà :

```bash
git tag --list | grep -x "<X.Y.Z>"    # doit ne rien renvoyer
```

**Si le fichier de version n'a pas de suffixe de pré-release** (version déjà "propre"), **ou si le
tag existe déjà**, s'arrêter et clarifier avec l'utilisateur avant de continuer — ne pas deviner un
numéro.

### 1. Notes de release — avant le tag

Générer les notes de `<dernier-tag>` à la HEAD qui va être taguée, et les faire merger sur la
branche par défaut **avant** de taguer : le tag livre alors le code et ses notes ensemble, sans
commit de rattrapage après coup. Voir le skill
[`generate-release-note`](../generate-release-note/SKILL.md).

### 2. Tag + push

```bash
git log --oneline | head -5          # repérer le dernier commit pertinent (pas un commit de bump seul)
git tag X.Y.Z <hash>                 # ce commit doit être un merge sur la branche par défaut
git push origin tag X.Y.Z            # déclenche le pipeline de release côté CI
```

Si le redéploiement ne suit pas automatiquement le push du tag côté CI (à vérifier par projet), le
dire explicitement plutôt que de supposer que le push du tag suffit.

### 3. Release GitHub (si le repo est sur GitHub)

Le tag poussé ne crée pas de release GitHub. La créer sur le tag existant, avec les notes de
l'étape 1 comme corps :

```bash
tail -n +3 <fichier-de-notes>.md > /tmp/notes-X.Y.Z.md   # corps sans le titre « # X.Y.Z — date »
gh release create X.Y.Z --verify-tag --title "X.Y.Z" --notes-file /tmp/notes-X.Y.Z.md
gh release list --limit 3                                 # X.Y.Z doit apparaître « Latest »
```

- `--verify-tag` : échoue si le tag n'est pas sur le remote, au lieu d'en créer un à la volée.
- Release rattrapée pour une version plus ancienne que la dernière : ajouter `--latest=false`.
- Visible en externe, comme le push : même règle de permission explicite (ci-dessous).

## Garde-fous avant de taguer

- **Jamais un commit de bump de version seul** (souvent marqué `[no ci]` ou équivalent) — pas de
  code utile derrière.
- **Jamais un commit de feature isolé** — le commit taggé doit être un merge sur la branche par
  défaut, sinon la release embarque un historique incohérent.
- Le tag livre **tout l'état de la branche par défaut** jusqu'à ce commit, pas juste le dernier
  changement — relire `git log origin/<dernier-tag>..<branche-par-défaut> --oneline` avant de
  taguer pour savoir ce qui part vraiment en release.
- Format de tag strict et cohérent avec l'historique existant (ex. semver `X.Y.Z`, avec ou sans
  préfixe `v` selon ce qui est déjà en usage sur ce repo — vérifier `git tag --list` plutôt que de
  supposer).

## Tag, push et release GitHub : seulement après permission explicite

Le tag, son push et la release GitHub sont difficiles à annuler et visibles en externe (ils
déploient en environnement de release). Avant de les lancer :

1. Afficher les commandes exactes (`git tag X.Y.Z <hash>`, `git push origin tag X.Y.Z`,
   `gh release create X.Y.Z ...`), avec le commit visé et le résultat des garde-fous ci-dessus.
2. Attendre la permission explicite de l'utilisateur **pour ce tour** — une permission donnée pour
   une release précédente ne vaut pas pour celle-ci.
3. Seulement ensuite, les exécuter. Ne jamais réécrire ni déplacer un tag déjà poussé.

À garantir côté settings plutôt qu'à laisser au jugement : règle `ask` sur `Bash(git push *)` (et
`Bash(git tag *)` si on veut aussi la demande sur le tag local, `Bash(gh release create *)` pour la
release GitHub) — voir
[`../../rules/permissions.md`](../../rules/permissions.md). Un projet qui veut garder le tag
entièrement manuel pose une règle `deny` à la place : Claude affiche alors les commandes à
copier-coller.

## Si le but n'est qu'un changement de config (pas de code)

Une release ne change **que le code**. Si ce qu'on veut propager est une variable d'environnement
(secret, allowlist, URL...), le tag est inutile — il faut juste que la valeur soit mise à jour côté
config de déploiement puis que le service redémarre, sans nouveau tag. Vérifier lequel des deux cas
s'applique avant de proposer une release.

---

## Exemple d'instanciation

Exemple générique d'adaptation sur un backend Spring Boot/Maven — donné à titre d'illustration du
niveau de détail attendu une fois ce skill adapté à un projet, pas à copier tel quel :

| Env | Image | Code livré | Déclencheur |
|---|---|---|---|
| Qualif | `:staging` | `main` HEAD | push sur `main` (workflow de build/déploiement staging) |
| Demo / Prod | `:stable` | dernier tag | push d'un tag `X.Y.Z` (workflow de préparation prod) |

Fichier de version : `pom.xml`, bump automatique à chaque merge par un commit dédié (type `build`,
résumé mentionnant la nouvelle version, marqué `[no ci]` pour ne pas redéclencher le pipeline). Le
redéploiement demo/prod suit automatiquement le push du tag, sans commande manuelle côté hôte.
