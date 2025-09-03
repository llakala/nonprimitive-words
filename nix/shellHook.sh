#!/user/bin/env bash

find_flake_root() {
  local dir=$PWD
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/flake.nix" ]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

oldHookDir=$(git config --local core.hooksPath)
newHookDir="$(find_flake_root)/.githooks"

if [ -z "$newHookDir" ]; then
    echo "Error: Could not find flake.nix to determine the project root."
    exit 1
fi

if [ "$oldHookDir" != "$newHookDir" ]; then
  read -rp "Set git hooks to $newHookDir? (y/n) " answer
  if [ "$answer" = "y" ]; then
    git config core.hooksPath "$newHookDir"
    echo "Set git hooks to $newHookDir"
  else
    echo "Skipping git hooks setup"
  fi
fi