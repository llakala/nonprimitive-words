oldHookDir=$(git config --local core.hooksPath)

if [ "$oldHookDir" != "$PWD/.githooks" ]; then
  read -rp "Set git hooks to $PWD/.githooks? (y/n) " answer
  if [ "$answer" = "y" ]; then
    git config core.hooksPath "$PWD"/.githooks
    echo "Set git hooks to $PWD/.githooks"
  else
    echo "Skipping git hooks setup"
  fi
fi
