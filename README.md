# Lean 4 Development Environment

A flake for developing with [Lean 4](https://github.com/leanprover/lean4).

## Targets

### Shell

Run the development environment with
```bash
nix develop
```
In that shell, you can access `lean`. For example: `lean --run Main.lean`.

Create dependencies for your project by running `make-deps`.

Start a VSCode instance with Lean extensions already configured for your project, by running `code`.

### Executable

You can compile your project into an executable with `nix build .#executable`.

# License

MIT