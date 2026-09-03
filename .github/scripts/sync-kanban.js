// Positionne le statut d'une issue sur le kanban (Projects v2) à partir d'un événement
// issue/PR, en s'appuyant sur la convention de nom de branche Git Flow
// (feature|release|hotfix/<ID-issue>-<slug>) documentée dans skills/git-flow/actions/feature.md.
// Voir .github/workflows/sync-kanban.yml pour le déclenchement, rules/git-flow.md pour le modèle.
module.exports = async ({ github, context, core }) => {
  const OWNER = "zYmMiJ";
  const PROJECT_NUMBER = 4;

  let targetStatus;
  let issueNumbers = [];

  if (context.eventName === "issues") {
    targetStatus = "Backlog";
    issueNumbers = [context.payload.issue.number];
  } else if (context.eventName === "pull_request") {
    const pr = context.payload.pull_request;
    const action = context.payload.action;

    if (action === "closed") {
      if (!pr.merged) {
        core.info("PR fermée sans merge — pas de synchronisation.");
        return;
      }
      targetStatus = "Terminé";
    } else if (action === "ready_for_review") {
      targetStatus = "En revue";
    } else if (action === "opened" || action === "reopened") {
      targetStatus = "En cours";
    } else {
      core.info(`Action PR "${action}" non mappée — rien à faire.`);
      return;
    }

    // Issue(s) référencée(s) : "#N" dans le titre/corps, ou nom de branche Git Flow.
    const text = `${pr.title}\n${pr.body || ""}`;
    const fromText = [...text.matchAll(/#(\d+)/g)].map((m) => Number(m[1]));
    const branchMatch = pr.head.ref.match(/^(?:feature|release|hotfix)\/(\d+)/);
    const fromBranch = branchMatch ? [Number(branchMatch[1])] : [];
    issueNumbers = [...new Set([...fromText, ...fromBranch])];

    if (issueNumbers.length === 0) {
      core.info(
        'Aucune issue référencée (ni "#N" dans le titre/corps, ni nom de branche ' +
          "feature|release|hotfix/<N>-...) — rien à synchroniser."
      );
      return;
    }
  } else {
    core.info(`Événement "${context.eventName}" non géré.`);
    return;
  }

  const { user } = await github.graphql(
    `query($owner: String!, $number: Int!) {
      user(login: $owner) {
        projectV2(number: $number) {
          id
          field(name: "Status") {
            ... on ProjectV2SingleSelectField { id options { id name } }
          }
        }
      }
    }`,
    { owner: OWNER, number: PROJECT_NUMBER }
  );
  const project = user.projectV2;
  const statusField = project.field;
  const option = statusField.options.find((o) => o.name === targetStatus);
  if (!option) {
    core.setFailed(`Option de statut "${targetStatus}" introuvable sur le champ Status.`);
    return;
  }

  for (const number of issueNumbers) {
    let issue;
    try {
      const res = await github.rest.issues.get({ ...context.repo, issue_number: number });
      issue = res.data;
    } catch {
      core.info(`Issue #${number} introuvable dans ${context.repo.owner}/${context.repo.repo} — ignorée.`);
      continue;
    }

    const { node } = await github.graphql(
      `query($id: ID!) {
        node(id: $id) {
          ... on Issue {
            projectItems(first: 20) { nodes { id project { id } } }
          }
        }
      }`,
      { id: issue.node_id }
    );
    const item = node.projectItems.nodes.find((n) => n.project.id === project.id);

    if (!item) {
      core.info(`Issue #${number} n'est pas (encore) dans le projet ${OWNER}/#${PROJECT_NUMBER} — ignorée.`);
      continue;
    }

    await github.graphql(
      `mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
        updateProjectV2ItemFieldValue(input: {
          projectId: $project, itemId: $item, fieldId: $field,
          value: { singleSelectOptionId: $option }
        }) { clientMutationId }
      }`,
      { project: project.id, item: item.id, field: statusField.id, option: option.id }
    );

    core.info(`Issue #${number} → statut "${targetStatus}".`);
  }
};
