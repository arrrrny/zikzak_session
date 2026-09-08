# Bug Issue: after_specify worktree hook fails on a commit-less repo

- **Slug**: worktree-create-empty-repo
- **Reported**: 2026-08-23
- **Issue**: 1
- **URL**: https://github.com/arrrrny/zikzak_session/issues/1
- **Severity**: high

The mandatory `after_specify` worktree hook (`speckit.worktrees.create`) cannot branch from an unborn `HEAD` on a repo with no commits, failing with a misleading "Run 'git fetch'" message. Filed against `arrrrny/zikzak_session`; the `severity:high` label does not exist in the new repo, so only the `bug` label was applied.
