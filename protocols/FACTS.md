# Facts

## Goal

Keep current truth separate from historical truth.

## Preferred Storage

Store durable facts on entity pages in `memory/wiki/entities/`.

## Required Sections

- `Current`
- `History`
- `Sources`

## Rules

- Do not silently overwrite outdated facts.
- Move superseded information into `History`.
- Note contradictions explicitly when sources disagree.
- Use evidence links when a fact matters operationally.

## Example

If a project changes direction:

- remove the old statement from `Current`
- add the new statement to `Current`
- record the old statement and when it changed under `History`
- link the decision or session page that explains the change

