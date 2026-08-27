# Repository

This is a chezmoi source directory, not a conventional application repository. Files here describe the desired state of files in the home directory; they are not necessarily copied there verbatim. There is no build, test suite, release process, or repository-wide formatting step.

## Source and Target State

- Respect chezmoi names and attributes. For example, `dot_config/` maps to `~/.config/`, `dot_codex/` to `~/.codex/`, and prefixes such as `private_`, `executable_`, `readonly_`, and `symlink_` encode target metadata.
- A `.tmpl` suffix makes a source file a template. Validate its rendered target content rather than treating it as a literal file.
- Preserve existing attributes when editing or moving entries. Check the chezmoi source-state attribute documentation before introducing an unfamiliar prefix.
- Hidden files in the source directory are ignored unless their names begin with `.chezmoi`.

## Editing and Validation

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
