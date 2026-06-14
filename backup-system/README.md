# Autonomous Backup System

A small, dependency-light, **self-hosting** backup system for a knowledge base / dotfiles / multi-repo setup. It gives you the **3-2-1 rule** (3 copies, 2 media, 1 off-site), runs itself, and is **plug-and-play** across machines and OSes.

It was built to protect a multi-layer "second brain" (an Obsidian vault + an engineering knowledge base + per-project memory + the machine-level agent config), but the engine is generic: **you describe what to back up in one JSON manifest, and the scripts do the rest.**

> Zero hard dependencies beyond `bash`, `git`, `jq`, `rsync`, `flock` (coreutils). No `yq`, no `bats`, no `gitleaks`, no cloud SDKs — so it restores on a bare machine.

---

## Why

Most "backups" are a static cron job that rots the moment your setup changes. This one is **declarative and self-hosting**: the rules live in a versioned `ckis-manifest.json` that is itself backed up, and discovery is registry-driven, so adding a repo or a tool is **one manifest entry** — never a script edit.

## How it works — three rings of autonomy

1. **Ring 1 — push on event (real time).** A git hook calls `ckis-push.sh <repo>` at the end of a work session: stage-all → commit-if-dirty → push with retry. Detached, lock-guarded, never blocks you. 100 new files = 1 commit = 1 push.
2. **Ring 2 — daily safety net.** A `systemd --user` timer runs `ckis-backup-all.sh`: reads the manifest, **auto-creates missing private remotes** (self-healing onboarding), pushes any drift, aggregates public repos' gitignored subdirs into a private repo, exports the curated config apparatus, and runs the physical backup if a drive is mounted.
3. **Ring 3 — passive visibility.** `ckis-backup-doctor.sh --oneline` prints a one-line health status (`BACKUP ✅ all pushed · physical 2d`) you can drop into a shell prompt or a session banner — so you see drift without checking.

## Layers it backs up

| Class | Meaning | Destination |
|---|---|---|
| `track` | source of truth (text/config/scripts) | private git remote |
| `regenerable` | derivable from tracked inputs | **excluded**, with a recorded rebuild command |
| `secret` | credentials/tokens/keys | **never** a remote — encrypted physical disk only |
| `sensitive` | private now, encrypt later | private remote (flagged for a future git-crypt repo) |
| `snapshot` | costly binary | physical disk / Git LFS, not the main repo |

## Install

```bash
git clone https://github.com/YOUR_USER/your-infra-repo.git ~/infra
cd ~/infra
cp ckis-manifest.example.json ckis-manifest.json
$EDITOR ckis-manifest.json            # set github_owner + your targets
./install.sh                          # symlinks bin/ -> ~/bin, systemd timer, secret-scan hooks
```

Wire Ring 1 into wherever a "work session" ends (a git `post-commit` hook, an editor hook, or an agent's stop hook):
```bash
~/bin/ckis-push "$HOME/path/to/repo" &
```

## Usage

```bash
ckis-backup-doctor            # health report
ckis-backup-all               # force a full run (push drift, aggregate, physical)
ckis-backup-physical          # physical backup to a mounted drive (auto-detected)
```

## Disaster restore (plug-and-play)

On a brand-new machine or OS:
```bash
gh auth login                                            # or set up git credentials
git clone https://github.com/YOUR_USER/your-infra-repo.git ~/infra
cd ~/infra && ./bin/ckis-restore.sh
```
It clones every target to its manifest path, restores the config apparatus, and installs the runtime. **The only manual step is re-providing secrets** — by design, they are never in the backup.

## Mobile (iOS + Android)

Every target is just a git repo, so any mobile git client works. For Obsidian vaults, the **obsidian-git** plugin (`isDesktopOnly:false`) syncs each vault on iOS and Android with a fine-grained PAT — which also sidesteps Obsidian Sync's one-vault limit.

## Design notes & hard-won lessons

- **`$HOME` may itself be a git repo.** A directory without its own `.git` then resolves to the `$HOME` repo, and `git add -A` will try to stage your entire home directory. Every script guards with `is_repo_root` and refuses to operate on a parent repo. *(This one cost an 11-minute CPU hang to find.)*
- **FAT/exFAT can't store `:` in filenames.** On FAT drives the per-file mirror is skipped; **git bundles** (single files holding full history + all filenames) are the authoritative physical copy.
- **Heavy/third-party content is `regenerable`, not backed up** — e.g. a skill that bundles a 1 GB headless browser is reinstalled, not committed.
- **Secrets never leave the machine.** A `pre-commit` secret scanner (dependency-free regex for GitHub/AWS/GCP keys + private keys) blocks accidental commits; the manifest `deny[]` and a defense-in-depth purge keep credentials out of the config export.

## Layout

```
bin/      ckis-push, ckis-backup-all, ckis-backup-doctor, ckis-backup-physical,
          cli-brains-sync, ckis-apparatus-export, ckis-restore
lib/      common.sh        (logging, flock, retry, manifest accessors, git helpers)
hooks/    pre-commit-secret-scan.sh
systemd/  ckis-backup.{service,timer}
tests/    pure-bash test harness (run: bash tests/run.sh) — 106 assertions
install.sh · ckis-manifest.example.json
```

## Tests

```bash
bash tests/run.sh     # bash -n + (optional) shellcheck + behavior tests -> GATE: ✅ GREEN
```

## License

See `LICENSE` in the repository root.
