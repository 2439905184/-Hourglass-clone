# Hourglass Maintenance

## Adding New Godot Versions

I usually find out about new releases (beta, RC, and stable) via Twitter.

To add a new version to Hourglass:

1. Run `scripts/add_version.py` with the ID of the new version, e.g.
   `./scripts/add_version.py 3.2.4-rc1`.
2. Copy the output and paste it at the top of `data/versions.cfg`.
3. Run `scripts/check_versions.py`. It will check each file referenced in
   versions.cfg, in order, to make sure the file exists on the server.
4. When all the files you just added are checked, press Ctrl+C to stop the
   script--you don't need to recheck all the hundreds of files each time.
5. If `check_versions.py` reported any errors, you'll need to find out the
   correct filename and fix it. You might need to fix `add_version.py` if
   the change is permanent.
6. Edit `data/info.cfg` and increment the `versions_cfg` number.
7. Make a commit with these two changes and push it to GitLab.
8. No Hourglass release is necessary. Just open Hourglass and make sure the
   new version is available.

## Releasing Hourglass

1. Read the git log since the last release and add a changelog to the top
   of `CHANGELOG.md`. Be sure to keep the formatting consistent!
2. Update the version string in `data/info.cfg`.
3. Create a commit with these two changes. For the commit message, use
   "RELEASE: " followed by the version string.
4. Tag this commit with the version string using `git tag`.
5. Push both the commit and the tag to GitLab.
6. Go to the website repo (<https://gitlab.com/jwestman/hourglass-website/>)
   and add the changelog as a new post. Posts are stored in the `_posts`
   directory; just copy and paste the previous post as a template.
7. Push the website repo changes to GitLab.
8. Announce the change on social media. Highlight any new features and include
   screenshots if applicable.
