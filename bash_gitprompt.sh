function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

git_staged() {
  if $(! git status -s &> /dev/null)
  then
    echo ""
  else
    addedStaged=0
    modifiedStaged=0
    deletedStaged=0
    stats=$(git status --porcelain)
    while IFS='' read -r line || [[ -n "$line" ]]; do
      status=${line:0:3}
      if [[ "$status" == 'A  ' ]]; then
        addedStaged=$((addedStaged + 1))
      elif [[ "$status" == 'M  ' ]]; then
        modifiedStaged=$((modifiedStaged + 1))
      elif [[ "$status" == 'D  ' ]]; then
        deletedStaged=$((deletedStaged + 1))
      fi
    done <<< "$stats"
    stagedStats="-"
    if [ "$addedStaged" -gt 0 ] || [ "$modifiedStaged" -gt 0 ] || [ "$deletedStaged" -gt 0 ]; then
      stagedStats="+$addedStaged ~$modifiedStaged -$deletedStaged"
    fi
    echo -e " $stagedStats"
  fi
}

git_unstaged() {
  if $(! git status -s &> /dev/null)
  then
    echo ""
  else
    untracked=0
    modified=0
    deleted=0
    stats=$(git status --porcelain)
    while IFS='' read -r line || [[ -n "$line" ]]; do
      status=${line:0:3}
      if [[ "$status" == '?? ' ]]; then
        untracked=$((untracked + 1))
      elif [[ "$status" == ' M ' ]]; then
        modified=$((modified + 1))
      elif [[ "$status" == ' D ' ]]; then
        deleted=$((deleted + 1))
      fi
    done <<< "$stats"
    unstagedStats="-"
    if [ "$untracked" -gt 0 ] || [ "$modified" -gt 0 ] || [ "$deleted" -gt 0 ]; then
      unstagedStats="+$untracked ~$modified -$deleted"
    fi
    echo -e " $unstagedStats"
  fi
}

export PS1="\[\033[00m\]\w\[\033[96m\]\$(parse_git_branch)\[\033[92m\]\$(git_staged)\[\033[91m\]\$(git_unstaged) \[\033[92m\]$\[\033[00m\] "
