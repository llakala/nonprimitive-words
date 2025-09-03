{
  pkgs,
  lib,
  ...
}: let
  mergeAttrSets = mergee: merging: let
    mergeeAttrs = lib.attrsToList mergee;
    mergingAttrs = lib.attrsToList merging;
  in
    builtins.foldl' (
      acc: elem:
        if acc ? ${elem.name}
        then
          # Check if they match
          if acc.${elem.name} == elem.value
          then acc # Do nothing
          # They don't match, let's attempt a save
          # If they are **both** sets, then we can start recursion to merge them
          else if (lib.typeOf acc.${elem.name} == "set") && (lib.typeOf elem.value == "set")
          then acc // {${elem.name} = mergeAttrSets acc.${elem.name} elem.value;}
          # If we got here, we know at least one of them is not a set, for debugging purposes, let's check if at least on is a set
          # Lets start by checking the a`cc value
          else if lib.typeOf acc.${elem.name} == "set"
          then
            throw ''
              Conflict detected when merging sets for attribute ${elem.name}:
              - First value is a set.
              - Whilst the second value is not: ${toString elem.value}
              These types cannot be merged.
            ''
          # Now we see if the elem value is a set
          else if lib.typeOf elem.value == "set"
          then
            throw ''
              Conflict detected when merging sets for attribute ${elem.name}:
              - First value is not a set: ${toString acc.${elem.name}}
              - Whilst the second value is a set.
              These types cannot be merged.
            ''
          # If we got here, we know for sure that neither of them are sets
          # We also know that they're not equal
          else
            throw ''
              Conflict detected when merging sets for attribute ${elem.name}:
              - First value: ${toString acc.${elem.name}}
              - Second value: ${toString elem.value}
              These values are not equal, and cannot be merged.
            ''
        # We know the attribute doesn't exist yet, so we can just add it
        else acc // {${elem.name} = elem.value;}
    ) {}
    (mergeeAttrs ++ mergingAttrs);
in
  attrSetList:
    builtins.foldl' (
      acc: elem:
        mergeAttrSets acc elem
    ) {}
    attrSetList
