# Autonomous Backup System

A small, dependency-light, **self-hosting** backup system for a knowledge base / dotfiles / multi-repo setup. It gives you the **3-2-1 rule** (3 copies, 2 media, 1 off-site), runs itself, and is **plug-and-play** across machines and OSes.

It was built to protect a multi-layer "second brain" (an Obsidian vault + an engineering knowledge base + per-project memory + the machine-level agent config), but the engine is generic: **you describe what to back up in one JSON manifest, and the scripts do the rest.**

> Zero hard dependencies beyond `bash`, `git`, `jq`, `rsync`, `flock` (coreutils). No `yq`, no `bats`, no `gitleaks`, no cloud SDKs — so it restores on a bare machine.

---

## Why

Most "backups" are a static cron job that rots the moment your setup changes. This one is **declarative and self-hosting**: the rules live in a versioned `ckis-manifest.json` that is itself backed up, and discovery is registry-driven, so adding a repo or a tool is **one manifest entry** — never a script edit.

## How it works — three rings of autonomy

1. **Ring 1 — push on event (fast path).** A git hook or session-stop hook calls `ckis-push.sh <repo>`: stage-all → commit-if-dirty → push with retry. Detached, lock-guarded, never blocks you. 100 new files = 1 commit = 1 push. **It fails hard** if a commit is blocked — never reports a stalled backup as success.
2. **Ring 2 — reconciling safety net (the real-time floor).** A `systemd --user` timer runs `ckis-backup-all.sh` on a short interval (default **15 min**, set in the manifest). Being a *reconcile* rather than an event hook makes it **tool-agnostic** — it captures changes no matter which editor/agent made them, with no `inotify` dependency. It auto-creates missing private remotes, pushes drift, **centralizes every project's memory subdir** (any tool, any visibility) into one private repo, exports the curated config apparatus, sweeps every `.git/config` for embedded credentials, runs a throttled deep secret-audit, and does the physical backup if a drive is mounted. **It exits non-zero on any real failure.**
3. **Ring 3 — passive visibility.** `ckis-backup-doctor.sh --oneline` prints a one-line health status (`BACKUP ✅ all pushed · physical 2d`) for a shell prompt or session banner. A blocked backup shows **🔴 FAILED** (a real problem), distinct from a benign **⚠** drift.

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
ckis-backup-doctor            # health report (🔴 FAILED = real block, ⚠ = benign drift)
ckis-backup-all               # force a full run (push drift, centralize, audit, physical)
ckis-secret-audit             # scan every repo's working tree + .git/config for real secrets
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
- **Secrets never leave the machine.** A dependency-free `pre-commit` scanner blocks accidental commits — but it detects **real key material**, not mentions: tokens are gated by Shannon **entropy** (so a `ghp_xxxx…` placeholder or a doc that quotes one passes), PEM keys require an actual base64 body next to the marker, and it also covers **`.git/config` remote-URL credentials** and `class=secret` filenames. A `.ckis-secret-allow` file (or an inline `ckis-allow-secret` marker) sanctions docs/tests that legitimately quote a pattern.
- **Silent success is the worst failure.** A backup that reports green while doing nothing is more dangerous than a crash. Marker-matching secret scanners false-positive on notes that *document* security work and can wedge a knowledge base's backup for hours; every failure path here exits non-zero and the banner shows 🔴, and `ckis-secret-audit` re-checks the whole system independently of any exit code.

## Layout

```
bin/      ckis-push, ckis-backup-all, ckis-backup-doctor, ckis-backup-physical,
          brains-sync, ckis-secret-audit, ckis-apparatus-export, ckis-restore
lib/      common.sh        (logging, flock, retry, entropy, failure markers,
                            agent-agnostic brain discovery, git helpers)
hooks/    pre-commit-secret-scan.sh
systemd/  ckis-backup.{service,timer}
tests/    pure-bash test harness (run: bash tests/run.sh) — 12 suites
install.sh · ckis-manifest.example.json
```

## Tests

```bash
bash tests/run.sh     # bash -n + (optional) shellcheck + behavior tests -> GATE: ✅ GREEN
```

## License

See `LICENSE` in the repository root.
