# Mod and Tooling Development Guidelines

> Executable contracts for this project's C# Mod and Python asset/build tooling.

---

## Overview

Read the project-specific contracts below before changing their layers. The older generic backend templates remain incomplete; they do not establish a web server or database architecture for this repository.

## Project-Specific Contracts

| Guide | Applies to | Status |
|-------|------------|--------|
| [Character Assets](./character-assets.md) | Legacy animation baking, manifest, Unity sprites and packaging | Code-backed |
| [Native Combat](./native-combat.md) | Hero hooks, combo clock, hit ownership, rendering and lifecycle | Code-backed, including original Wukong nail arcs with native charm range and mesh restoration, source travel, original Wukong death/dash immunity and native-end-aligned30Hz Fire Eye casting clock/overlay/aura and downward dash art and up/down/focus adapters, neutral-spell Storm / down-Dream Afterimage routes; unreleased Storm attribution draft has no enemy interruption support; client acceptance pending |

Before implementation, read the applicable contract and `.trellis/spec/guides/index.md`. During quality review, verify the cross-layer schema and ownership rules and run the relevant tests/build; actual client checks remain separate.

---

## Guidelines Index

| Guide | Description | Status |
|-------|-------------|--------|
| [Directory Structure](./directory-structure.md) | Module organization and file layout | To fill |
| [Database Guidelines](./database-guidelines.md) | ORM patterns, queries, migrations | To fill |
| [Error Handling](./error-handling.md) | Error types, handling strategies | To fill |
| [Quality Guidelines](./quality-guidelines.md) | Code standards, forbidden patterns | To fill |
| [Logging Guidelines](./logging-guidelines.md) | Structured logging, log levels | To fill |

---

## How to Fill These Guidelines

For each guideline file:

1. Document your project's **actual conventions** (not ideals)
2. Include **code examples** from your codebase
3. List **forbidden patterns** and why
4. Add **common mistakes** your team has made

The goal is to help AI assistants and new team members understand how YOUR project works.

---

**Language**: All documentation should be written in **English**.
