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
