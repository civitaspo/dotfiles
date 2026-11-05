# OpenIn

Paste `github-pr-to-linear-review.js` into an OpenIn rule or default handler
script. GitHub pull request links processed by that script are rewritten
to `linear://review/` links; other links are unchanged. Pull request subpaths, query
parameters, and fragments are removed.

Paste `slack-message-to-app.js` into a Slack URL rule and replace `YOUR_TEAM_ID`
with the Slack workspace ID before saving it in OpenIn.
