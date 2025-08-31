#!/bin/bash

# Git CTF Challenges - Real Repository Setup Script
# This script sets up Git CTF challenges in the current Git repository.
# Usage:
#   ./create-git-challenges.sh [--challenges <1,3,5>] [--cleanup]
# Options:
#   --challenges <list>  Comma-separated list of challenge numbers to set up (e.g., 1,3,5)
#   --cleanup           Remove challenge branches and files, then exit

set -e

# Configuration
REPO_NAME="git-ctf-challenges"
CHALLENGES="all"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --challenges)
            CHALLENGES="$2"
            shift 2
            ;;
        --cleanup)
            CLEANUP="true"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors for output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
NC=$(tput sgr0) # No Color
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git and try again."
    fi
    if ! command -v patch &> /dev/null; then
        log_error "Patch command is not installed. Please install patch and try again."
    fi
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        log_error "Current directory is not a Git repository. Please run in a Git repository."
    fi
    if ! git rev-parse main &>/dev/null; then
        log_error "Branch 'main' does not exist. Please ensure the repository has a 'main' branch."
    fi
    log_success "Dependencies verified."
}

# Check disk space (require at least 10MB)
check_disk_space() {
    log_info "Checking disk space..."
    local required_space=10240 # 10MB in KB
    local available_space
    available_space=$(df -k . | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt "$required_space" ]; then
        log_error "Insufficient disk space. Required: 10MB, Available: $((available_space / 1024))MB"
    fi
    log_success "Sufficient disk space available."
}

# Cleanup function
cleanup() {
    log_info "Cleaning up repository..."
    branches=(
        "level_1_detached_head"
        "level_2_tag_treasure"
        "level_3_bisect_hunt"
        "level_4_stash_investigation"
        "level_5_patch_analysis"
        "level_6_lost_commit"
        "level_7_api_key_leak"
        "level_8_decoy"
        "level_8_wrong"
        "level_8_secret"
        "level_9_rebase_maze"
        "level_10_time_traveler"
        "level_11_imposter"
        "level_12_vault"
    )
    for branch in "${branches[@]}"; do
        if git rev-parse --verify "$branch" &>/dev/null; then
            git branch -D "$branch" || log_error "Failed to delete branch $branch"
            log_success "Branch $branch removed."
        fi
    done
    # Remove challenge-related files
    files=(
        "README.md"
        "app.py"
        "config.py"
        "secret_note.txt"
        "bisect_setup.txt"
        "secret_code.py"
        "decoy.py"
        "final_secret.py"
        "original.py"
        "fix1.patch"
        "fix2.patch"
        "secrets.py"
        ".env"
        "flag.txt"
        "rebase_flag.txt"
        "time_travel_flag.txt"
        "imposter_flag.txt"
        "clue.txt"
        "final_clue.txt"
        "CHALLENGE_SUMMARY.md"
        "HINTS.md"
    )
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            git rm -f "$file" || log_error "Failed to remove $file"
        fi
    done
    if git status --porcelain | grep -q .; then
        git commit -m "Cleanup: Remove challenge files" || log_error "Failed to commit cleanup"
    fi
    # Remove tags
    tags=("v1.0" "checkpoint" "treasure" "decoy" "v1.0-alpha")
    for tag in "${tags[@]}"; do
        if git rev-parse --verify "refs/tags/$tag" &>/dev/null; then
            git tag -d "$tag" || log_error "Failed to delete tag $tag"
        fi
    done
    log_success "Repository cleaned up."
    exit 0
}

# Check for existing branch and prompt to overwrite
check_and_create_branch() {
    local branch_name="$1"
    local base_branch="$2"
    if git rev-parse --verify "$branch_name" &>/dev/null; then
        read -p "Branch $branch_name exists. Delete and recreate it? [y/N] " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            git branch -D "$branch_name" || log_error "Failed to delete existing branch $branch_name"
            git checkout -b "$branch_name" "$base_branch" || log_error "Failed to create branch $branch_name"
        else
            log_error "Aborted: Branch $branch_name already exists."
        fi
    else
        git checkout -b "$branch_name" "$base_branch" || log_error "Failed to create branch $branch_name"
    fi
}

# Create initial project files
create_initial_files() {
    log_info "Creating initial project files..."

    if [ -f "README.md" ] || [ -f "app.py" ] || [ -f "config.py" ]; then
        read -p "Initial files (README.md, app.py, config.py) exist. Overwrite them? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_error "Aborted: Initial files already exist."
        fi
    fi

    cat > README.md << 'EOF'
# Git CTF Challenges Repository

This repository contains real Git scenarios for Capture-the-Flag challenges to help you master Git commands and concepts.

## Challenges Included

### Beginner
1. **Detached Head Nightmare** - Recover from detached HEAD state
2. **Tag Treasure Hunt** - Find hidden messages in Git tags

### Intermediate
3. **Git Bisect Hunt** - Use binary search to find bugs
4. **Stash Investigation** - Recover stashed changes
5. **Patch Analysis** - Apply and analyze Git patches

### Advanced
6. **The Lost Commit** - Recover deleted commits
7. **API Key Leak** - Find committed secrets
8. **Branch Analysis Maze** - Navigate complex branch structures

### Expert
9. **The Rebase Maze** - Solve complex rebase scenarios
10. **The Time Traveler** - Detect corrupted history
11. **The Imposter** - Find suspicious commits
12. **The Vault** - Ultimate multi-step challenge

## How to Use

Each challenge is in a separate branch, except for Tag Treasure Hunt and Branch Analysis Maze, which use the main branch. Start with the main branch and explore! Check HINTS.md in each branch for guidance.

Good luck! 🚩
EOF

    cat > app.py << 'EOF'
# Welcome to the Git CTF!
# This is the main application file.

print("Hello, World!")
print("Welcome to Git CTF Lab!")
EOF

    cat > config.py << 'EOF'
# Configuration file
DEBUG = True
APP_NAME = "Git CTF Lab"
EOF

    git add . || log_error "Failed to add initial files"
    git commit -m "Initial commit: Add project structure" || log_error "Failed to commit initial files"

    log_success "Initial files created"
}

# Create hints file for a challenge
create_hints_file() {
    local challenge_number="$1"
    local challenge_name="$2"
    local hints="$3"
    local branch="$4"
    cat > HINTS.md << EOF
# Hints for Challenge $challenge_number: $challenge_name

$hints

**Branch**: \`$branch\`

Explore the repository to find the flag using Git commands!
EOF
    git add HINTS.md || log_error "Failed to add HINTS.md"
    git commit -m "docs: Add hints for challenge $challenge_number" || log_error "Failed to commit HINTS.md"
}

# Challenge 1: Detached Head Nightmare
setup_detached_head_challenge() {
    log_info "Setting up Challenge 1: Detached Head Nightmare..."
    echo "This challenge teaches you how to recover from a 'detached HEAD' state."
    echo "A detached HEAD occurs when you check out a commit that is not the latest in a branch."

    check_and_create_branch "level_1_detached_head" "main"

    cat >> app.py << 'EOF'

def new_feature():
    print("This is a new feature!")
    return "Feature working"
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add new functionality" || log_error "Failed to commit new functionality"

    cat >> config.py << 'EOF'

# New configuration
FEATURE_ENABLED = True
EOF

    git add config.py || log_error "Failed to add config.py"
    git commit -m "feat: Enable new feature" || log_error "Failed to commit new feature"

    echo "Configuration update completed." > secret_note.txt
    git add secret_note.txt || log_error "Failed to add secret_note.txt"
    git commit -m "feat: Add secret configuration - FLAG{DETACHED_HEAD_SURVIVOR}" || log_error "Failed to commit secret configuration"

    git checkout HEAD~1 || log_error "Failed to checkout detached HEAD state"

    create_hints_file "1" "Detached Head Nightmare" "You are in a detached HEAD state. The flag is in the commit message of a recent commit.\n- Use \`git reflog\` to see recent actions.\n- Find the commit that added 'secret_note.txt'.\n- Use \`git log --oneline\` or \`git show\` to view the commit message." "level_1_detached_head"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 1: Detached Head Nightmare ready"
}

# Challenge 2: Tag Treasure Hunt
setup_tag_treasure_hunt() {
    log_info "Setting up Challenge 2: Tag Treasure Hunt..."
    echo "This challenge teaches you how to find information hidden in Git tags."
    echo "Tags can be simple pointers or annotated objects with messages."

    git checkout main || log_error "Failed to checkout main"

    cat >> app.py << 'EOF'

def utility_function():
    return "Utility"
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add utility function" || log_error "Failed to commit utility function"

    git tag v1.0 || log_error "Failed to create tag v1.0"
    git tag -a checkpoint -m "Version 1.0 checkpoint - almost there" || log_error "Failed to create annotated tag checkpoint"

    cat >> config.py << 'EOF'

# Version info
VERSION = "1.1"
EOF

    git add config.py || log_error "Failed to add config.py"
    git commit -m "feat: Update version to 1.1" || log_error "Failed to commit version update"

    git tag -a treasure -m "FLAG{TAG_EXPLORER} hidden in plain sight" || log_error "Failed to create annotated tag treasure"
    git tag decoy || log_error "Failed to create tag decoy"

    create_hints_file "2" "Tag Treasure Hunt" "The flag is hidden in a tag's message.\n- Use \`git tag -n\` to list all tags with their messages.\n- Use \`git show <tag>\` to inspect annotated tags." "main"

    log_success "Challenge 2: Tag Treasure Hunt ready"
}

# Challenge 3: Git Bisect Hunt
setup_bisect_hunt() {
    log_info "Setting up Challenge 3: Git Bisect Hunt..."
    echo "This challenge teaches you how to use 'git bisect' to find the commit that introduced a bug."
    echo "'git bisect' performs a binary search through your commit history."

    check_and_create_branch "level_3_bisect_hunt" "main"

    cat >> app.py << 'EOF'

def working_function():
    return "Working correctly"
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add working function" || log_error "Failed to commit working function"

    GOOD_COMMIT=$(git rev-parse HEAD) || log_error "Failed to get good commit hash"

    for i in {1..5}; do
        echo "# Change $i" >> config.py
        git add config.py || log_error "Failed to add config.py"
        git commit -m "refactor: Neutral change $i" || log_error "Failed to commit neutral change"
    done

    cat >> app.py << 'EOF'

def working_function():
    return "This is broken!"  # Bug introduced here
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Update function (accidentally broke it) - FLAG{BISECT_EXPERT}" || log_error "Failed to commit broken function"

    BAD_COMMIT=$(git rev-parse HEAD) || log_error "Failed to get bad commit hash"

    git checkout main || log_error "Failed to checkout main"

    cat > bisect_setup.txt << 'EOF'
Git Bisect Hunt Challenge

There is a bug in the 'level_3_bisect_hunt' branch. The 'working_function' in 'app.py' is broken.
Your mission is to find the commit that introduced the bug. The flag is in the commit message.

Good commit (working): $GOOD_COMMIT
Bad commit (broken): $BAD_COMMIT

Use 'git bisect' to find the bad commit.

Hint: 
1. git checkout level_3_bisect_hunt
2. git bisect start
3. git bisect bad $BAD_COMMIT
4. git bisect good $GOOD_COMMIT
5. Test the function (check if it returns "Working correctly" or "This is broken!")
6. git bisect reset
EOF

    git add bisect_setup.txt || log_error "Failed to add bisect_setup.txt"
    git commit -m "docs: Add bisect challenge setup" || log_error "Failed to commit bisect setup"

    create_hints_file "3" "Git Bisect Hunt" "The flag is in the commit message of the commit that broke 'working_function'.\n- Use \`git bisect\` to find the bad commit.\n- Start with the good and bad commits provided in bisect_setup.txt.\n- Use \`git log --oneline\` to check the commit message." "level_3_bisect_hunt"

    log_success "Challenge 3: Git Bisect Hunt ready"
}

# Challenge 4: Stash Investigation
setup_stash_investigation() {
    log_info "Setting up Challenge 4: Stash Investigation..."
    echo "This challenge teaches you how to recover changes from the Git stash."
    echo "The stash is a temporary storage area for your work-in-progress."

    check_and_create_branch "level_4_stash_investigation" "main"

    cat > secret_code.py << 'EOF'
# Secret code - DO NOT COMMIT
API_KEY = "secret-api-key"
# No flag here, check the stash message
EOF

    git stash push -m "WIP: Secret work - FLAG{STASH_DETECTIVE}" || log_error "Failed to stash secret work"

    cat >> app.py << 'EOF'

def public_function():
    return "Public functionality"
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add public function" || log_error "Failed to commit public function"

    cat > decoy.py << 'EOF'
# Decoy file
DECOY_KEY = "not-a-real-key"
EOF

    git stash push -m "WIP: Decoy work" || log_error "Failed to stash decoy work"

    cat > final_secret.py << 'EOF'
# Final secret
SECRET_VALUE = "no-flag-here"
EOF

    git stash push -m "WIP: Decoy secret" || log_error "Failed to stash decoy secret"

    create_hints_file "4" "Stash Investigation" "The flag is hidden in a stash message.\n- Use \`git stash list\` to see all stashes.\n- Use \`git stash show -p <stash>\` to inspect stash contents.\n- Check the stash message for the flag." "level_4_stash_investigation"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 4: Stash Investigation ready"
}

# Challenge 5: Patch Analysis
setup_patch_analysis() {
    log_info "Setting up Challenge 5: Patch Analysis..."
    echo "This challenge teaches you how to apply and analyze Git patches."
    echo "Patches are a way to share changes without pushing to a remote repository."

    check_and_create_branch "level_5_patch_analysis" "main"

    cat > original.py << 'EOF'
print("Original functionality")
def original_function():
    return "Original"
EOF

    git add original.py || log_error "Failed to add original.py"
    git commit -m "feat: Add original function" || log_error "Failed to commit original function"

    cat > fix1.patch << 'EOF'
--- a/original.py
+++ b/original.py
@@ -1,4 +1,4 @@
 print("Original functionality")
 def original_function():
-    return "Original"
+    return "Fixed v1"
EOF

    patch -p1 < fix1.patch || log_error "Failed to apply fix1.patch"
    git add original.py || log_error "Failed to add patched original.py"
    git commit -m "fix: Apply first fix" || log_error "Failed to commit first fix"

    # Base64 encode the flag
    encoded_flag=$(echo -n "FLAG{PATCH_ANALYST}" | base64)
    cat > fix2.patch << EOF
--- a/original.py
+++ b/original.py
@@ -1,4 +1,4 @@
 print("Original functionality")
 def original_function():
-    return "Fixed v1"
+    return "$encoded_flag"  # Decode this with base64
EOF

    git add fix1.patch fix2.patch || log_error "Failed to add patch files"
    git commit -m "feat: Add patch files" || log_error "Failed to commit patch files"

    create_hints_file "5" "Patch Analysis" "The flag is in a patch file but encoded.\n- Use \`git apply fix2.patch\` or \`patch -p1 < fix2.patch\` to apply the second patch.\n- The result in original.py is base64-encoded. Decode it using \`echo <value> | base64 -d\`." "level_5_patch_analysis"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 5: Patch Analysis ready"
}

# Challenge 6: The Lost Commit
setup_lost_commit() {
    log_info "Setting up Challenge 6: The Lost Commit..."
    echo "This challenge teaches you how to recover a commit that was accidentally deleted from the branch history."
    echo "'git reset --hard' can be dangerous, but 'git reflog' can save you."

    check_and_create_branch "level_6_lost_commit" "main"

    cat >> app.py << 'EOF'

def normal_function():
    return "Normal operation"
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add normal function" || log_error "Failed to commit normal function"

    cat > secrets.py << 'EOF'
# Database configuration
DB_HOST = "localhost"
DB_USER = "admin"
DB_PASS = "password123"
# No flag here, check the commit message
EOF

    git add secrets.py || log_error "Failed to add secrets.py"
    git commit -m "feat: Add database configuration - FLAG{LOST_COMMIT_RECOVERED_2024}" || log_error "Failed to commit database configuration"

    git reset --hard HEAD~1 || log_error "Failed to reset to HEAD~1"

    create_hints_file "6" "The Lost Commit" "The flag is in the commit message of a deleted commit.\n- Use \`git reflog\` to find the lost commit.\n- Use \`git show <commit>\` to view the commit message." "level_6_lost_commit"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 6: The Lost Commit ready"
}

# Challenge 7: API Key Leak
setup_api_key_leak() {
    log_info "Setting up Challenge 7: API Key Leak..."
    echo "This challenge teaches you how to find sensitive information that was accidentally committed to the repository."
    echo "It's crucial to never commit secrets to version control."

    check_and_create_branch "level_7_api_key_leak" "main"

    cat >> app.py << 'EOF'

import os

def get_config():
    return {"debug": True}
EOF

    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add config function" || log_error "Failed to commit config function"

    cat > .env << 'EOF'
API_KEY="decoy-key-123"
DB_URL="localhost:5432"
DEBUG_MODE=true
SECRET_KEY="super_secret_key_123"
REAL_API_KEY="FLAG{SECURITY_AUDITOR}"
DECOY_KEY="not-the-flag"
EOF

    git add .env || log_error "Failed to add .env"
    git commit -m "feat: Add real environment configuration" || log_error "Failed to commit real environment configuration"

    rm .env || log_error "Failed to remove .env"
    git add .env || log_error "Failed to add removed .env"
    git commit -m "fix: Remove sensitive environment file" || log_error "Failed to commit environment file removal"

    create_hints_file "7" "API Key Leak" "The flag is in a removed .env file.\n- Use \`git log -p\` to view the commit history and find the commit that added .env.\n- Look for the real API key among decoys." "level_7_api_key_leak"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 7: API Key Leak ready"
}

# Challenge 8: Branch Analysis Maze
setup_branch_analysis_maze() {
    log_info "Setting up Challenge 8: Branch Analysis Maze..."
    echo "This challenge tests your ability to navigate a repository with many branches."
    echo "Not all branches are created equal!"

    git checkout main || log_error "Failed to checkout main"

    check_and_create_branch "level_8_decoy" "main"
    echo "This is not the flag" > flag.txt
    git add flag.txt || log_error "Failed to add flag.txt"
    git commit -m "feat: Add decoy flag" || log_error "Failed to commit decoy flag"

    git checkout main || log_error "Failed to checkout main"
    check_and_create_branch "level_8_wrong" "main"
    echo "WRONG_FLAG" > flag.txt
    git add flag.txt || log_error "Failed to add flag.txt"
    git commit -m "feat: Add wrong flag" || log_error "Failed to commit wrong flag"

    git checkout main || log_error "Failed to checkout main"
    check_and_create_branch "level_8_secret" "main"
    echo "Secret data" > flag.txt
    git add flag.txt || log_error "Failed to add flag.txt"
    git commit -m "feat: Add secret flag - FLAG{BRANCH_ANALYST}" || log_error "Failed to commit secret flag"

    create_hints_file "8" "Branch Analysis Maze" "The flag is in the commit message of a specific branch.\n- Use \`git branch -a\` to list all branches.\n- Check each branch's latest commit message with \`git log --oneline\`." "main (check level_8_decoy, level_8_wrong, level_8_secret)"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 8: Branch Analysis Maze ready"
}

# Challenge 9: The Rebase Maze
setup_rebase_maze() {
    log_info "Setting up Challenge 9: The Rebase Maze..."
    echo "This challenge teaches you how to resolve conflicts during a 'git rebase'."
    echo "Rebasing is a powerful tool, but it can be tricky when there are conflicts."

    check_and_create_branch "level_9_rebase_maze" "main"

    echo "# Feature A" >> app.py
    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add feature A" || log_error "Failed to commit feature A"

    git checkout main || log_error "Failed to checkout main"

    echo "# Feature B" >> app.py
    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add feature B" || log_error "Failed to commit feature B"

    git checkout level_9_rebase_maze || log_error "Failed to checkout level_9_rebase_maze"

    echo "# Conflicting change" >> app.py
    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add conflicting change" || log_error "Failed to commit conflicting change"

    echo "Rebase preparation complete." > rebase_flag.txt
    git add rebase_flag.txt || log_error "Failed to add rebase_flag.txt"
    git commit -m "feat: Add rebase flag - FLAG{REBASE_MASTER}" || log_error "Failed to commit rebase flag"

    create_hints_file "9" "The Rebase Maze" "The flag is in the commit message after rebasing.\n- Use \`git rebase main\` on the level_9_rebase_maze branch.\n- Resolve conflicts in app.py.\n- Use \`git add\` and \`git rebase --continue\` to complete the rebase.\n- Check the commit message with \`git log --oneline\`." "level_9_rebase_maze"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 9: The Rebase Maze ready"
}

# Challenge 10: The Time Traveler
setup_time_traveler() {
    log_info "Setting up Challenge 10: The Time Traveler..."
    echo "This challenge teaches you how to detect and analyze commits with altered timestamps."
    echo "Commit timestamps can be manipulated, which can be a sign of malicious activity."

    check_and_create_branch "level_10_time_traveler" "main"

    git commit --amend -m "feat: Add normal operation" --date="2024-01-01T12:00:00" --no-edit || log_error "Failed to amend commit"

    echo "# Suspicious change" >> app.py
    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add suspicious change" --date="2023-12-31T12:00:00" || log_error "Failed to commit with old date"

    echo "Future data" > time_travel_flag.txt
    git add time_travel_flag.txt || log_error "Failed to add time_travel_flag.txt"
    git commit -m "feat: Add time travel flag - FLAG{TIME_TRAVELER}" --date="2025-01-01T12:00:00" || log_error "Failed to commit with future date"

    create_hints_file "10" "The Time Traveler" "The flag is in the commit message of a commit with a future timestamp.\n- Use \`git log --pretty=fuller\` to inspect commit and author dates.\n- Look for a commit dated in the future." "level_10_time_traveler"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 10: The Time Traveler ready"
}

# Challenge 11: The Imposter
setup_imposter() {
    log_info "Setting up Challenge 11: The Imposter..."
    echo "This challenge teaches you how to identify commits made by an imposter."
    echo "You can set your Git username and email to anything, so it's important to be able to verify the author of a commit."

    check_and_create_branch "level_11_imposter" "main"

    git commit --amend -m "feat: Add legitimate feature" --author="Legit Developer <legit@example.com>" --no-edit || log_error "Failed to amend commit"

    echo "# Imposter's change" >> app.py
    git add app.py || log_error "Failed to add app.py"
    git commit -m "feat: Add imposter's feature - FLAG{IMPOSTER_DETECTED}" --author="Imposter <imposter@example.com>" || log_error "Failed to commit as imposter"

    echo "Imposter data" > imposter_flag.txt
    git add imposter_flag.txt || log_error "Failed to add imposter_flag.txt"
    git commit -m "feat: Add imposter data" --author="Imposter <imposter@example.com>" || log_error "Failed to commit imposter data"

    create_hints_file "11" "The Imposter" "The flag is in the commit message of an imposter's commit.\n- Use \`git log --pretty=full\` to see author and committer information.\n- Identify commits by 'Imposter <imposter@example.com>'." "level_11_imposter"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 11: The Imposter ready"
}

# Challenge 12: The Vault
setup_the_vault() {
    log_info "Setting up Challenge 12: The Vault..."
    echo "This is the final challenge! It combines several of the skills you've learned so far."

    check_and_create_branch "level_12_vault" "main"

    # Step 1: Hide a clue in a deleted commit
    echo "Clue 1: The next clue is in a tag named 'v1.0-alpha'" > clue.txt
    git add clue.txt || log_error "Failed to add clue.txt"
    git commit -m "feat: Add first clue" || log_error "Failed to commit first clue"
    git reset --hard HEAD~1 || log_error "Failed to reset and delete clue commit"

    # Step 2: Hide a clue in a tag
    git tag -a v1.0-alpha -m "Clue 2: The next clue is in a stash" || log_error "Failed to create alpha tag"

    # Step 3: Hide the flag in a stash
    echo "Final clue data" > final_clue.txt
    git stash push -m "Super secret clue - FLAG{VAULT_MASTER_2024}" || log_error "Failed to stash the final clue"

    create_hints_file "12" "The Vault" "The flag is hidden in a multi-step challenge.\n- Start with \`git reflog\` to find a deleted commit.\n- Follow the clue to a tag with \`git show v1.0-alpha\`.\n- Use \`git stash list\` to find the stash with the flag in its message." "level_12_vault"

    git checkout main || log_error "Failed to checkout main"

    log_success "Challenge 12: The Vault ready"
}

# Create challenge summary
create_challenge_summary() {
    log_info "Creating challenge summary..."

    if [ -f "CHALLENGE_SUMMARY.md" ]; then
        read -p "CHALLENGE_SUMMARY.md exists. Overwrite it? [y/N] " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_error "Aborted: CHALLENGE_SUMMARY.md already exists."
        fi
    fi

    cat > CHALLENGE_SUMMARY.md << 'EOF'
# Git CTF Challenges - Repository Summary

This repository contains 12 real Git challenges for learning and teaching Git concepts.

## Challenge Overview

### Beginner Challenges (🌱)
1. **Detached Head Nightmare**
   - **Branch**: `level_1_detached_head`
   - **Skill**: Recovering from detached HEAD state
   - **Objective**: Recover a lost commit to find the flag in its message.

2. **Tag Treasure Hunt**
   - **Branch**: `main`
   - **Skill**: Finding hidden messages in Git tags
   - **Objective**: Inspect tags to find the flag in an annotated tag's message.

### Intermediate Challenges (📈)
3. **Git Bisect Hunt**
   - **Branch**: `level_3_bisect_hunt`
   - **Skill**: Binary search for bug hunting
   - **Objective**: Use git bisect to find the commit that introduced a bug and check its message.

4. **Stash Investigation**
   - **Branch**: `level_4_stash_investigation`
   - **Skill**: Recovering stashed changes
   - **Objective**: Find the flag in a stash message.

5. **Patch Analysis**
   - **Branch**: `level_5_patch_analysis`
   - **Skill**: Applying and analyzing Git patches
   - **Objective**: Apply a patch and decode the base64-encoded flag.

### Advanced Challenges (🔥)
6. **The Lost Commit**
   - **Branch**: `level_6_lost_commit`
   - **Skill**: Recovering deleted commits using reflog
   - **Objective**: Recover a deleted commit to find the flag in its message.

7. **API Key Leak**
   - **Branch**: `level_7_api_key_leak`
   - **Skill**: Finding committed secrets
   - **Objective**: Search commit history to find a leaked API key.

8. **Branch Analysis Maze**
   - **Branch**: `main` (with `level_8_decoy`, `level_8_wrong`, `level_8_secret`)
   - **Skill**: Navigating complex branch structures
   - **Objective**: Find the correct branch and check its commit message for the flag.

### Expert Challenges (🏆)
9. **The Rebase Maze**
   - **Branch**: `level_9_rebase_maze` (with `main`)
   - **Skill**: Complex rebase scenarios with conflicts
   - **Objective**: Rebase the branch and resolve conflicts to find the flag in a commit message.

10. **The Time Traveler**
    - **Branch**: `level_10_time_traveler`
    - **Skill**: Detecting corrupted Git history
    - **Objective**: Find a commit with a future timestamp and check its message.

11. **The Imposter**
    - **Branch**: `level_11_imposter`
    - **Skill**: Identifying imposter commits
    - **Objective**: Identify the imposter's commit and find the flag in its message.

12. **The Vault** (Multi-step)
    - **Branch**: `level_12_vault`
    - **Skill**: Multi-step problem solving
    - **Objective**: Follow clues through reflog, tags, and stashes to find the flag in a stash message.
EOF

    git add CHALLENGE_SUMMARY.md || log_error "Failed to add CHALLENGE_SUMMARY.md"
    git commit -m "docs: Add comprehensive challenge summary" || log_error "Failed to commit challenge summary"

    log_success "Challenge summary created"
}

# Main execution function
main() {
    echo "🎯 Git CTF Challenges - Real Repository Setup"
    echo "=========================================="

    check_dependencies
    check_disk_space

    if [ "$CLEANUP" = "true" ]; then
        cleanup
    fi

    if [ "$CHALLENGES" != "all" ]; then
        log_info "Setting up selected challenges: $CHALLENGES"
        challenges=(${CHALLENGES//,/ })
    else
        challenges=(1 2 3 4 5 6 7 8 9 10 11 12)
    fi

    create_initial_files

    for challenge in "${challenges[@]}"; do
        case $challenge in
            1) setup_detached_head_challenge ;;
            2) setup_tag_treasure_hunt ;;
            3) setup_bisect_hunt ;;
            4) setup_stash_investigation ;;
            5) setup_patch_analysis ;;
            6) setup_lost_commit ;;
            7) setup_api_key_leak ;;
            8) setup_branch_analysis_maze ;;
            9) setup_rebase_maze ;;
            10) setup_time_traveler ;;
            11) setup_imposter ;;
            12) setup_the_vault ;;
            *) log_error "Invalid challenge number: $challenge" ;;
        esac
    done

    create_challenge_summary

    git checkout main &> /dev/null

    echo ""
    echo "🎉 Git CTF Challenges Repository Setup Complete!"
    echo "=========================================="
    echo ""
    echo "📁 Repository updated in current directory"
    echo "🌟 Total challenges: ${#challenges[@]}"
    echo "📚 Documentation: CHALLENGE_SUMMARY.md"
    echo ""
    echo "🚀 Quick Start:"
    echo "   git branch -a"
    echo "   cat CHALLENGE_SUMMARY.md"
    echo "   cat HINTS.md (on each challenge branch)"
    echo ""
    log_success "Repository ready for Git CTF challenges!"

    echo ""
    echo "🌿 Available Branches:"
    git branch -a || log_error "Failed to list branches"
}

main "$@"
