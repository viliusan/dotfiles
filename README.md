# dotfiles

Personal dev-tool configs. Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink into `~/.config`.

## Layout

Each top-level folder is a Stow "package" mirroring the structure it targets in `$HOME`:

```
ghostty/   -> ~/.config/ghostty/config
zed/       -> ~/.config/zed/{settings.json,keymap.json}
nvim/      -> ~/.config/nvim (LazyVim)
karabiner/ -> ~/.config/karabiner
```

## Bootstrap on a new Mac

```sh
brew install stow
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Adding a new config

1. Move the file into the matching package folder, preserving its path relative to `$HOME`.
   Example: `~/.config/foo/bar` -> `foo/.config/foo/bar`.
2. `stow foo` from `~/dotfiles`.
