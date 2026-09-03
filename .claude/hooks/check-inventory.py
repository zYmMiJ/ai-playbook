#!/usr/bin/env python3
"""Stop : rappelle que le tableau "Inventaire" du README.md doit suivre skills/agents/rules/prompts.

Se déclenche une fois par tour (voir stop_hook_active ci-dessous), pas à chaque édition — sinon ça
relancerait le rappel avant même d'avoir fini de rédiger un skill. Deux cas détectés à partir de
`git status --porcelain` :

- un fichier **ajouté/non tracké** sous skills/*/SKILL.md, agents/*.md, rules/*.md, prompts/*.md
  dont le chemin n'apparaît dans aucune ligne du README.md -> entrée d'inventaire manquante.
- un fichier **supprimé** sous ces mêmes dossiers dont le chemin apparaît encore dans le
  README.md -> entrée d'inventaire devenue orpheline (skill/agent/rule/prompt qui n'existe plus).

Ne vérifie pas les fichiers seulement *modifiés* : une entrée existante peut être mise à jour sans
que la ligne d'inventaire change de contenu, pas détectable de façon fiable par ce script — reste
à la vigilance de Claude au moment de l'édition, pas à ce hook.
"""
import json
import os
import subprocess
import sys

# top-level dossier -> filtre sur le chemin relatif à ce dossier
TRACKED = {
    "skills": lambda p: p.endswith("/SKILL.md"),
    "agents": lambda p: p.endswith(".md") and os.path.basename(p) != "README.md",
    "rules": lambda p: p.endswith(".md") and os.path.basename(p) != "README.md",
    "prompts": lambda p: p.endswith(".md") and os.path.basename(p) != "README.md",
}


def tracked_path(path: str) -> bool:
    top = path.split("/", 1)[0]
    check = TRACKED.get(top)
    return bool(check and check(path))


def main() -> int:
    try:
        data = json.load(sys.stdin)
    except Exception:
        return 0

    # Évite une boucle infinie : ne bloque qu'une fois par tour.
    if data.get("stop_hook_active"):
        return 0

    project_dir = os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()

    try:
        out = subprocess.run(
            # -uall : liste chaque fichier d'un nouveau dossier non tracké individuellement,
            # au lieu de le regrouper en une seule ligne "dossier/" (cas d'un nouveau skill —
            # skills/<nom>/SKILL.md ne serait sinon jamais détecté).
            ["git", "status", "--porcelain", "-uall"],
            cwd=project_dir, capture_output=True, text=True, check=True, timeout=10,
        ).stdout
    except Exception:
        return 0

    added, deleted = [], []
    for line in out.splitlines():
        if len(line) < 4:
            continue
        status, path = line[:2], line[3:]
        if " -> " in path:  # rename : "ancien -> nouveau"
            path = path.split(" -> ", 1)[1]
        if not tracked_path(path):
            continue
        if "D" in status:
            deleted.append(path)
        elif "A" in status or "?" in status:
            added.append(path)

    if not added and not deleted:
        return 0

    readme_path = os.path.join(project_dir, "README.md")
    try:
        with open(readme_path, encoding="utf-8") as f:
            readme = f.read()
    except FileNotFoundError:
        return 0

    missing = [p for p in added if p not in readme]
    orphaned = [p for p in deleted if p in readme]
    if not missing and not orphaned:
        return 0

    msg = ["Tableau \"Inventaire\" du README.md pas à jour :"]
    if missing:
        msg.append("- ajoutés mais absents du tableau : " + ", ".join(missing))
    if orphaned:
        msg.append("- supprimés mais encore référencés : " + ", ".join(orphaned))
    msg.append("Mettre à jour le tableau correspondant avant de terminer.")
    sys.stderr.write("\n".join(msg) + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main())
