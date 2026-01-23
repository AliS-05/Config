#!/bin/bash

# ===================== CONFIG =====================

PROGRAMMING_DIRECTORY="/mnt/d/programming"
REPO_CACHE="$HOME/.top_git_repos"
NVIM_LOG="$HOME/.nvim_edits"
QUOTES_FILE="$HOME/quotes.txt"

# ===================== COLORS =====================

PINK="\e[38;5;217m"
PEACH="\e[38;5;215m"
CORAL="\e[38;5;203m"
YELLOW="\e[38;5;229m"
ORANGE="\e[38;5;215m"
CYAN="\e[38;5;159m"
LAVENDER="\e[38;5;183m"
RESET="\e[0m"

printAscii() {
    # Prints an ASCII art file (you can randomize later)
    ASCII_FILE="/mnt/d/programming/bash/test/ascii.txt"
    if [[ -f "$ASCII_FILE" ]]; then
        echo -e "${CORAL}"
        cat "$ASCII_FILE"
        echo -e "${RESET}"
    else
        echo -e "${RED}ASCII file not found at $ASCII_FILE${RESET}"
    fi
    echo
}

# ===================== REPO DISCOVERY =====================

discover_git_repos() {
    find "$PROGRAMMING_DIRECTORY" -type d -name ".git" 2>/dev/null \
        | sed 's|/.git$||'
}

update_top_git_repos_cache() {
    discover_git_repos | while read -r repo; do
        commits=$(git -C "$repo" log --since="7 days ago" --oneline 2>/dev/null | wc -l)
        echo "$commits|$repo"
    done \
    | sort -rn \
    | head -3 \
    | cut -d'|' -f2 \
    > "$REPO_CACHE"
}

# ===================== STATS =====================

git_commits_this_week() {
    echo -e "${PINK}Git commits this week:${RESET}"
    for repo in "${TOP_REPOS[@]}"; do
        name=$(basename "$repo")
        count=$(git -C "$repo" log --since="7 days ago" --oneline 2>/dev/null | wc -l)
        echo -e "  ${CYAN}$name${RESET}: $count"
    done
    echo
}

nvim_files_edited_yesterday() {
    yesterday=$(date -d "yesterday" +%Y-%m-%d)
    if [[ -f "$NVIM_LOG" ]]; then
        count=$(grep "^$yesterday" "$NVIM_LOG" | wc -l)
    else
        count=0
    fi
    echo -e "${CORAL}Files edited yesterday in nvim:${RESET} ${ORANGE}$count${RESET}"
    echo
}

commands_ran_yesterday() {
    yesterday=$(date -d "yesterday" +%Y-%m-%d)
    count=$(grep "^$yesterday" "$HISTFILE" 2>/dev/null | wc -l)
    echo -e "${YELLOW}Commands ran yesterday:${RESET} ${ORANGE}$count${RESET}"
    echo
}

top_commands_yesterday() {
    yesterday=$(date -d "yesterday" +%Y-%m-%d)
    echo -e "${PEACH}Most used commands yesterday (top 3):${RESET}"
    grep "^$yesterday" "$HISTFILE" 2>/dev/null \
        | awk '{CMD[$2]++} END {for (c in CMD) print CMD[c], c}' \
        | sort -rn \
        | head -3
    echo
}

loc_this_week() {
    echo -e "${CYAN}Lines of code added/removed this week:${RESET}"
    for repo in "${TOP_REPOS[@]}"; do
        name=$(basename "$repo")
        git -C "$repo" log --since="7 days ago" --numstat --pretty=tformat: 2>/dev/null \
            | awk '
                { added += $1; removed += $2 }
                END {
                    printf "  %s: +%d / -%d\n", "'"$name"'", added, removed
                }'
    done
    echo
}

random_quote() {
    if [[ -f "$QUOTES_FILE" ]]; then
        echo -e "${LAVENDER}Quote of the day:${RESET} $(shuf -n 1 "$QUOTES_FILE")"
    else
        echo -e "${CORAL}Quote file not found at $QUOTES_FILE${RESET}"
    fi
    echo
}

# ===================== DISPLAY =====================

print_daily_tasks() {
    echo -e "${PEACH}Daily tasks:${RESET}"
    echo "1. Anki"
    echo "2. Reading"
    echo "3. Notes"
    echo "4. Go outside"
    echo
}

# ===================== ENTRY =====================

if [[ "$1" == "--update-cache" ]]; then
    update_top_git_repos_cache
    exit 0
fi

if [[ -f "$REPO_CACHE" ]]; then
    mapfile -t TOP_REPOS < "$REPO_CACHE"
else
    TOP_REPOS=()
fi

# Startup dashboard
printAscii
print_daily_tasks
git_commits_this_week
nvim_files_edited_yesterday
commands_ran_yesterday
top_commands_yesterday
loc_this_week
random_quote
cprompt
cdpro
