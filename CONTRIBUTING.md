# Contributing

If you are contributing, please title your branches <initials>/<branch-name>.

Make sure your pull request does not pull in any files it did not need to change.
If this happens, checkout the origin files from master (or some other appropriate
branch) like so:

    git checkout master -- <the-file>/<you-did>/<not-change>.txt

Once your pull request has been approved, please squash all commits into one like
so:

    git rebase -i HEAD~<number-of-commits-in-pr>
