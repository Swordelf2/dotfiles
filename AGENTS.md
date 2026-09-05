# Repository

This is a chezmoi source directory, not a conventional application repository. Files here describe the desired state of files in the home directory; they are not necessarily copied there verbatim. There is no build, test suite, release process, or repository-wide formatting step.

## Source and Target State

- Respect chezmoi names and attributes. For example, `dot_config/` maps to `~/.config/`, `dot_codex/` to `~/.codex/`, and prefixes such as `private_`, `executable_`, `readonly_`, and `symlink_` encode target metadata.
- A `.tmpl` suffix makes a source file a template. Validate its rendered target content rather than treating it as a literal file.
- Preserve existing attributes when editing or moving entries. Check the chezmoi source-state attribute documentation before introducing an unfamiliar prefix.
- Hidden files in the source directory are ignored unless their names begin with `.chezmoi`.

## Editing and Validation

### Session Workflow

For the main Codex conversation, run this workflow once at the first
mutation-authorized turn:

1. Report `git status`.
2. If the worktree or index has changes, run `git add -A`, inspect the staged
   content for credentials, tokens, machine identifiers, or unredacted private
   configuration, and commit it as
   `[codex-auto:pre] <concise summary of the existing changes>`.
3. Run `chezmoi re-add`.
4. If `re-add` changes the repository, run `git add -A`, perform the same
   sensitive-data inspection, and commit it as
   `[codex-auto:re-add] <concise summary of the imported live changes>`.

Before finishing a mutation-authorized task:

1. Run relevant validation.
2. Run `git add -A`, inspect the staged content for sensitive data, and, if
   anything is staged, commit it as
   `[codex-auto:work] <concise summary of the completed task>`.
3. Run `chezmoi status` and `chezmoi diff --no-pager`.
4. If the preview contains unexpected target drift, deletions, scripts, or
   unrelated paths, do not apply; report the issue instead.
5. Otherwise, run exactly `chezmoi apply --exclude=scripts`. Do not add targets
   or other flags, especially `--force`, `--init`, `--destination`, or
   `--source`.
6. Verify that `chezmoi status --exclude=scripts` is clean.

The text after each `[codex-auto:*]` tag must describe the relevant contents of
that commit, not merely restate the workflow stage. Do not create empty
commits, amend or squash existing commits, or push automatically. If a
sensitive-data inspection or commit fails, stop before the next step and
report it. Plan-only and review-only sessions remain non-mutating; run the
start workflow if the session later becomes mutation-authorized.

### Docs

* Edit source-state files in this repository directly. 
* Prefer official docs/repo over third-party examples.

### Editing

* Inspect the existing config before editing.
* Prefer clear and concise working code.
* Make focused edits and preserve the style of the file being changed. Lua files use tabs; continued shell constructs use four spaces.
* Treat monitor and host settings as machine-specific; use templates for genuine per-machine differences.

## Sensitive Data

Never commit credentials, tokens, machine identifiers, or unredacted private configuration. The `private_` prefix only restricts target permissions; it does not encrypt repository contents. 

# Dotfiles / PC configuration

User's preferences:

* Arch + Hyprland,
* keyboard driven, vim keybindings preferred
* clean and nice-looking visuals, catppuccin-macchiato theme
