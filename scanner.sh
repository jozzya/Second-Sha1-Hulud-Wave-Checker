#!/bin/bash

LOCKFILE="package-lock.json"
IMPORT_FILE="import.json"
MATCH_COUNT=0 

echo "Starting package version check against $IMPORT_FILE and $LOCKFILE..."
echo "---"

while IFS=',' read -r pkg ver; do

    
    # Removes leading range operators (like ^, ~ and whitespace).
    CLEAN_VER=$(printf "%s" "$ver" | sed 's/^[~^> \t]*//')
    
    # This query checks all three possible locations for a match in v3 of npm package-lock.json.
    match_exists=$(jq -r \
        --arg pkg "$pkg" \
        --arg ver "$ver" \
        --arg clean_ver "$CLEAN_VER" '
        
        # Define a function that checks for a match based on package name and EITHER version.
        def version_matches: . == $ver or . == $clean_ver;

        # Define the complete matching logic.
        def check_match:
          # 1. Check Root Dependencies (packages."".dependencies)
          (
              (.packages."".dependencies | has($pkg)) 
              and (.packages."".dependencies[$pkg] | version_matches)
          )
          
          # 2. Check All Other Package Entries (Resolved packages OR Transitive Dependencies)
          or 
          (
              .packages
              | to_entries
              | any(
                  .key != "" and 
                  .value.name == $pkg and 
                  (
                       .value.version | version_matches                      # Match Resolved Version
                       or (.value.dependencies?[$pkg]? | version_matches)   # Match Transitive Dependency Version
                  )
              )
          );

        check_match
    ' "$LOCKFILE")

    if [[ "$match_exists" == "true" ]]; then
        # Check for complex version strings to determine what to print.
        if [[ "$ver" != "$CLEAN_VER" ]]; then
            echo "❌ Package **$pkg** matches version **$ver** (cleaned to **$CLEAN_VER**)"
        else
            echo "❌ Package **$pkg** matches version **$ver**"
        fi
        MATCH_COUNT=$((MATCH_COUNT + 1)) 
    else
        echo "Package **$pkg** version **$ver** not found in package-lock.json"
    fi

done < <(jq -r '
  . | to_entries | .[] | "\(.key),\(.value)"
' "$IMPORT_FILE")

echo "---"
echo "Check complete."
echo "Total matches found: **$MATCH_COUNT**"