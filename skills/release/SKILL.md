---
name: release
description: >
  Donne les commandes exactes pour sortir une release via tag Git (calcul du tag, garde-fous, push)
  — sans jamais les exécuter soi-même. Se déclenche pour "sortir une release", "déployer en prod",
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

## Release — déterminer le tag, puis tag + push

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

### 1. Tag + push

```bash
git log --oneline | head -5          # repérer le dernier commit pertinent (pas un commit de bump seul)
git tag X.Y.Z <hash>                 # ce commit doit être un merge sur la branche par défaut
git push origin tag X.Y.Z            # déclenche le pipeline de release côté CI
```

Si le redéploiement ne suit pas automatiquement le push du tag côté CI (à vérifier par projet), le
dire explicitement plutôt que de supposer que le push du tag suffit.

### 2. Notes de release — une fois la release validée

À faire seulement **après** que l'utilisateur confirme que la release déployée est bonne (pas juste
taguée/pushée) — pas avant, pas automatiquement à la suite de l'étape 1. Voir le skill
[`generate-release-note`](../generate-release-note/SKILL.md).

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

## Interdiction absolue : ne jamais push ni tagger soi-même

Ce skill ne fait que **donner les commandes** ci-dessus — il ne les exécute jamais. `git tag` et
`git push origin tag ...` restent à taper par l'utilisateur lui-même, sans exception, même si
l'utilisateur dit explicitement "go" ou "lance la release" : dans ce cas, réafficher les commandes
prêtes à copier-coller, pas les exécuter. C'est une action difficile à annuler et visible en externe
(déploie en environnement de release) — elle sort du périmètre de ce que Claude fait pour ce repo.

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
