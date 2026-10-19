# websitehunt-feed

Daily candidate websites for [WebsiteHunt](https://www.websitehunt.co), collected by GitHub Actions.

Every day at 05:17 UTC, `collect.py`:

1. Fetches new links from Hacker News (stories with 100+ points in the last two days) and Pinboard popular.
2. Skips any canonical URL already in `data/`.
3. Opens each link in headless Chromium and records the final URL, title, description, OG image, favicon and a text excerpt.
4. Asks [Jev](https://typesafe.ai) for an interest score (0–4) and a WebsiteHunt category.
5. Saves a screenshot to `shots/` for links scoring 3.0 or higher.
6. Commits `data/YYYY/MM-DD.json` (that day's new links) and `latest.json` (the last 14 days, best first).

`latest.json` is what WebsiteHunt reads. Sources that fail are listed in its `coverage_gaps` rather than failing the run.

## Run locally

```bash
JEV_API_KEY=... uv run collect.py
```

The `JEV_API_KEY` repository secret is used in Actions.
