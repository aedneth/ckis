---
name: video-editor
description: >
  Edit, trim, concat, convert, compress, or otherwise transform video files from the
  terminal using ffmpeg. Use when [OWNER] says "video-editor", "edit video", "cut video",
  "ffmpeg edit", "render video", "trim video", "concat video", "compress video", "extract
  audio", "burn subtitles", "make a gif from video", or any other one-off video task.
  Picks the correct ffmpeg recipe from a 20-pattern library, executes it, verifies the
  output with ffprobe, and stores the result in the right `assets/` folder.
argument-hint: "describe the operation: e.g. 'trim input.mp4 from 00:10 to 00:30', 'concat clips/*.mp4', 'extract audio from talk.mkv', 'compress demo.mp4 under 25MB'"
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
metadata:
  author: [OWNER]
  version: 1.0.0
  ckis-context: true
  category: media-processing
---

# Video Editor (ffmpeg)

> Standard ffmpeg recipe library + execution harness for the terminal. Created after the 2026-05-29 CKIS demo reel needed three precise cuts (00:16–01:03 + 01:20–01:40 + 03:10–03:43) concatenated into one web-friendly MP4 — the multi-clip filter_complex pattern was rebuilt from scratch in chat instead of being a one-line skill invocation. This skill captures the 20 most common terminal video operations so the next edit takes seconds, not a debugging session.

━━━

## Scope

This skill handles **single-machine, single-pass video edits** using the local `ffmpeg` binary. It covers:

- Trimming, cutting, and multi-clip highlight reels
- Concatenation (with and without re-encoding)
- Format conversion, resizing, framerate changes
- Audio: extract, replace, mute, normalize
- Speed changes (slow-mo, time-lapse)
- Overlays: text, watermarks, subtitles (burn-in and soft)
- Two-pass encoding for strict size targets
- CRF quality tuning
- GIF creation, thumbnail extraction
- Vertical crop for social platforms (9:16)

**Do NOT touch**:
- `.obsidian/` folder
- Source videos in user-protected locations (`~/Videos/`, `~/Documents/`) without explicit confirmation
- Existing rendered outputs without backup if they took >5 minutes to produce
- Files larger than 5 GB without confirming disk space first

━━━

## Pre-conditions

Before running, verify:

1. [ ] `ffmpeg` and `ffprobe` are installed (`command -v ffmpeg`)
2. [ ] Input file(s) exist and are readable
3. [ ] Output directory exists or can be created (default: `assets/<type>/`)
4. [ ] Disk has at least 2× the input size free (re-encoding can double temporarily)

**Decision tree — pick re-encode vs stream copy**:

- **Stream copy (`-c copy`, fast, lossless)** when: changing container only (MKV→MP4), trimming on keyframe boundaries, concatenating same-codec files, swapping audio without changing video
- **Re-encode (slow, lossy)** when: changing resolution, framerate, codec; applying filters (scale, overlay, drawtext, crop); trimming to sub-second precision; multi-clip `filter_complex` edits

**Decision tree — pick CRF vs two-pass**:

- **CRF (single-pass, quality-targeted)** when: no strict size limit, you want consistent visual quality
- **Two-pass (ABR, size-targeted)** when: file must fit under a hard ceiling (Discord 25 MB, Twitter 512 MB, etc.)

━━━

## Phase 1 — Identify the Task

Parse [OWNER]'s request into:

- **Operation type** (trim / concat / convert / compress / extract-audio / overlay / gif / thumbnail / speed / crop / normalize)
- **Input(s)** — absolute path(s) or glob
- **Output** — absolute path, default to `assets/<type>/<descriptive-name>.<ext>`
- **Constraints** — size limit, target resolution, quality preference, time range

If any required piece is ambiguous, ask [OWNER] before running ffmpeg.

━━━

## Phase 2 — Select the Recipe

Match the parsed task to one of the 20 recipes below. If two recipes apply, prefer the simpler one (stream copy over re-encode, single-pass over two-pass).

━━━

## Recipe Library

### 1 · Highlight reel — multi-clip filter_complex

**When**: Multiple non-contiguous segments from one source file → single output.

```bash
ffmpeg -y -i "$INPUT" \
  -filter_complex "
    [0:v]trim=start=16:end=63,setpts=PTS-STARTPTS[v1];
    [0:a]atrim=start=16:end=63,asetpts=PTS-STARTPTS[a1];
    [0:v]trim=start=80:end=100,setpts=PTS-STARTPTS[v2];
    [0:a]atrim=start=80:end=100,asetpts=PTS-STARTPTS[a2];
    [0:v]trim=start=190:end=223,setpts=PTS-STARTPTS[v3];
    [0:a]atrim=start=190:end=223,asetpts=PTS-STARTPTS[a3];
    [v1][a1][v2][a2][v3][a3]concat=n=3:v=1:a=1[outv][outa]
  " \
  -map "[outv]" -map "[outa]" \
  -c:v libx264 -crf 23 -preset medium \
  -profile:v high -level:v 4.0 -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -movflags +faststart "$OUTPUT"
```

`setpts=PTS-STARTPTS` resets each segment's timeline to 0 so concat sees clean inputs. `concat=n=N:v=1:a=1` joins N video+audio pairs. Add/remove `[vN][aN]` blocks symmetrically and update `n=`.

Reference: `scripts/edit-ckis-demo-video.sh`.

━━━

### 2 · Simple trim — single clip, single span

**When**: Cut one continuous segment from a longer source.

```bash
# Fast trim on keyframe (no re-encode, may snap to nearest keyframe)
ffmpeg -y -ss 00:00:10 -to 00:00:30 -i "$INPUT" -c copy "$OUTPUT"

# Precise trim (re-encode for exact frame accuracy)
ffmpeg -y -i "$INPUT" -ss 00:00:10 -to 00:00:30 \
  -c:v libx264 -crf 20 -preset medium -c:a aac -b:a 128k "$OUTPUT"
```

Put `-ss`/`-to` **before** `-i` for fast seek (decoder skips upstream). Put them **after** `-i` for frame-accurate seek (decoder reads through). Use `HH:MM:SS.ms` or raw seconds.

━━━

### 3 · Concat without re-encoding — same-codec files

**When**: Joining files that share codec, resolution, framerate, audio params.

```bash
# Build concat list
printf "file '%s'\n" /abs/path/clip1.mp4 /abs/path/clip2.mp4 /abs/path/clip3.mp4 > /tmp/concat.txt

ffmpeg -y -f concat -safe 0 -i /tmp/concat.txt -c copy "$OUTPUT"
```

Lightning fast — no transcode. Fails if codecs differ — fall back to Recipe 1 (filter_complex concat) if so.

━━━

### 4 · Scale / resize

**When**: Change output resolution (downscale for web, upscale rarely useful).

```bash
# Exact 1280x720
ffmpeg -y -i "$INPUT" -vf "scale=1280:720" \
  -c:v libx264 -crf 23 -preset medium -c:a copy "$OUTPUT"

# Keep aspect ratio — width 1280, auto height (must be even)
ffmpeg -y -i "$INPUT" -vf "scale=1280:-2" \
  -c:v libx264 -crf 23 -preset medium -c:a copy "$OUTPUT"
```

`-2` (not `-1`) forces even dimension required by yuv420p.

━━━

### 5 · Change framerate

**When**: Convert 60fps → 30fps for smaller file, or normalize variable framerate.

```bash
ffmpeg -y -i "$INPUT" -vf "fps=30" \
  -c:v libx264 -crf 23 -preset medium -c:a copy "$OUTPUT"

# Alternative: -r flag (sets output framerate, may drop/dup frames)
ffmpeg -y -i "$INPUT" -r 30 -c:v libx264 -crf 23 -c:a copy "$OUTPUT"
```

Prefer `fps` filter — handles variable framerate input cleanly.

━━━

### 6 · Extract audio

**When**: Strip video, save audio only.

```bash
# Lossless copy (only works if container supports the audio codec)
ffmpeg -y -i "$INPUT" -vn -acodec copy "$OUTPUT_AUDIO.m4a"

# Re-encode to MP3
ffmpeg -y -i "$INPUT" -vn -c:a libmp3lame -q:a 2 "$OUTPUT_AUDIO.mp3"

# Re-encode to WAV (uncompressed, for editing)
ffmpeg -y -i "$INPUT" -vn -c:a pcm_s16le -ar 44100 "$OUTPUT_AUDIO.wav"
```

`-q:a 2` = MP3 VBR ~190 kbps (near-transparent). `-vn` = no video.

━━━

### 7 · Replace audio track — stream copy video

**When**: Swap dubbed/replacement audio onto existing video without re-encoding video.

```bash
ffmpeg -y -i "$VIDEO_INPUT" -i "$NEW_AUDIO" \
  -map 0:v -map 1:a \
  -c:v copy -c:a aac -b:a 192k \
  -shortest "$OUTPUT"
```

`-map 0:v` takes video from input 0, `-map 1:a` takes audio from input 1. `-shortest` truncates to the shorter stream.

━━━

### 8 · Mute audio

**When**: Remove the audio track entirely.

```bash
ffmpeg -y -i "$INPUT" -c:v copy -an "$OUTPUT"
```

`-an` strips audio. `-c:v copy` keeps video bit-perfect.

━━━

### 9 · Speed up / slow down

**When**: Time-lapse (faster) or slow-mo (slower).

```bash
# 2× faster (video + audio)
ffmpeg -y -i "$INPUT" \
  -filter_complex "[0:v]setpts=0.5*PTS[v];[0:a]atempo=2.0[a]" \
  -map "[v]" -map "[a]" "$OUTPUT"

# 0.5× (slow-mo)
ffmpeg -y -i "$INPUT" \
  -filter_complex "[0:v]setpts=2.0*PTS[v];[0:a]atempo=0.5[a]" \
  -map "[v]" -map "[a]" "$OUTPUT"

# 4× faster (atempo range is 0.5–2.0 — chain for >2× or <0.5×)
ffmpeg -y -i "$INPUT" \
  -filter_complex "[0:v]setpts=0.25*PTS[v];[0:a]atempo=2.0,atempo=2.0[a]" \
  -map "[v]" -map "[a]" "$OUTPUT"
```

`setpts` factor is **inverse** of speed (0.5 = 2× faster). `atempo` is **direct** (2.0 = 2× faster). Chain `atempo` for extremes.

━━━

### 10 · Add text overlay — burn-in caption

**When**: Need a title card or persistent caption baked into the video.

```bash
ffmpeg -y -i "$INPUT" \
  -vf "drawtext=text='CKIS Demo':fontfile=/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf:fontsize=48:fontcolor=white:x=(w-text_w)/2:y=50:box=1:boxcolor=black@0.5:boxborderw=10" \
  -c:v libx264 -crf 20 -preset medium -c:a copy "$OUTPUT"
```

`x=(w-text_w)/2` centers horizontally. Add `enable='between(t,0,5)'` to limit to 0–5 seconds.

━━━

### 11 · Add watermark / logo overlay

**When**: Brand a video with a corner logo (PNG with transparency).

```bash
ffmpeg -y -i "$INPUT" -i "$LOGO_PNG" \
  -filter_complex "[0:v][1:v]overlay=W-w-20:H-h-20" \
  -c:v libx264 -crf 20 -preset medium -c:a copy "$OUTPUT"
```

`W-w-20` = bottom-right with 20px margin (W=video width, w=logo width). Top-left: `20:20`. Center: `(W-w)/2:(H-h)/2`.

━━━

### 12 · Subtitles

**When**: Add captions for accessibility or translation.

```bash
# Burn-in (hard subs, can't be turned off)
ffmpeg -y -i "$INPUT" -vf "subtitles=$SRT_FILE" \
  -c:v libx264 -crf 20 -preset medium -c:a copy "$OUTPUT"

# Soft subs in MP4 (toggleable in player)
ffmpeg -y -i "$INPUT" -i "$SRT_FILE" \
  -c:v copy -c:a copy -c:s mov_text "$OUTPUT"

# Soft subs in MKV
ffmpeg -y -i "$INPUT" -i "$SRT_FILE" \
  -c:v copy -c:a copy -c:s srt "$OUTPUT"
```

For styled burn-in, use `.ass` subtitle file with `ass` filter instead of `subtitles`.

━━━

### 13 · Format conversion

**When**: Cross-container conversion for compatibility.

```bash
# MKV → MP4 (usually stream copy works)
ffmpeg -y -i "$INPUT.mkv" -c copy "$OUTPUT.mp4"

# WebM → MP4 (needs re-encode — VP9/Opus → H.264/AAC)
ffmpeg -y -i "$INPUT.webm" \
  -c:v libx264 -crf 23 -preset medium \
  -c:a aac -b:a 128k "$OUTPUT.mp4"

# MOV → MP4 (usually stream copy)
ffmpeg -y -i "$INPUT.mov" -c copy -movflags +faststart "$OUTPUT.mp4"
```

If stream copy fails with "could not find tag for codec", re-encode.

━━━

### 14 · Two-pass encoding — strict size target

**When**: Output must be ≤ N MB (Discord 25, Twitter 512, GitHub 100, etc.).

```bash
TARGET_SIZE_MIB=25
DURATION_SEC=$(ffprobe -v quiet -show_entries format=duration -of csv=p=0 "$INPUT")
AUDIO_BITRATE_KBPS=128
TARGET_TOTAL_KBITS=$(( TARGET_SIZE_MIB * 8 * 1024 ))
AUDIO_TOTAL_KBITS=$(awk "BEGIN{print int(${AUDIO_BITRATE_KBPS} * ${DURATION_SEC})}")
VIDEO_KBPS=$(awk "BEGIN{print int((${TARGET_TOTAL_KBITS} - ${AUDIO_TOTAL_KBITS}) / ${DURATION_SEC})}")

# Pass 1 — analyze
ffmpeg -y -i "$INPUT" -c:v libx264 -b:v "${VIDEO_KBPS}k" \
  -preset medium -pass 1 -passlogfile /tmp/ff2pass -an -f null /dev/null

# Pass 2 — encode
ffmpeg -y -i "$INPUT" -c:v libx264 -b:v "${VIDEO_KBPS}k" \
  -preset medium -pass 2 -passlogfile /tmp/ff2pass \
  -c:a aac -b:a "${AUDIO_BITRATE_KBPS}k" \
  -movflags +faststart "$OUTPUT"

rm -f /tmp/ff2pass-0.log /tmp/ff2pass-0.log.mbtree
```

Pass 1 has no audio and writes to `/dev/null` — only the log matters. Pass 2 uses the log to allocate bits optimally across the timeline.

━━━

### 15 · CRF tuning reference

CRF (Constant Rate Factor) for `libx264` / `libx265`:

| CRF | Quality | Use case |
|-----|---------|----------|
| 18  | Visually lossless | Archive, color grading source |
| 20  | High | Production master, paid distribution |
| 23  | Default / good | Web demos, social media (libx264 default) |
| 26  | Acceptable | Quick share, bandwidth-constrained |
| 28  | Compressed | Last-resort small file (libx265 default ≈23) |

Lower = better quality, larger file. `libx265` runs ~6 CRF points lower for equivalent quality (CRF 28 H.265 ≈ CRF 23 H.264).

`-preset` trades encode speed for compression efficiency: `ultrafast` < `superfast` < `veryfast` < `faster` < `fast` < `medium` (default) < `slow` < `slower` < `veryslow`. Each step roughly doubles encode time for ~5% smaller files at same CRF.

━━━

### 16 · GIF creation — high-quality palette

**When**: Video clip → optimized GIF for chat / docs.

```bash
# Two-step for quality (palettegen + paletteuse)
PALETTE=/tmp/palette.png

ffmpeg -y -i "$INPUT" -vf "fps=15,scale=640:-2:flags=lanczos,palettegen=stats_mode=diff" "$PALETTE"

ffmpeg -y -i "$INPUT" -i "$PALETTE" \
  -lavfi "fps=15,scale=640:-2:flags=lanczos[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" \
  "$OUTPUT.gif"
```

15 fps + 640 width keeps GIFs under ~5 MB for 10-second clips. Drop to fps=10 for further savings.

━━━

### 17 · Thumbnail extraction

**When**: Single frame at a timestamp, or a grid of frames for previews.

```bash
# Single frame at 00:00:15
ffmpeg -y -ss 00:00:15 -i "$INPUT" -frames:v 1 -q:v 2 "$OUTPUT.jpg"

# 4×4 grid of evenly-spaced frames (16 total)
ffmpeg -y -i "$INPUT" -vf "select='not(mod(n\,$(ffprobe -v quiet -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of csv=p=0 "$INPUT")/16))',scale=320:-1,tile=4x4" \
  -frames:v 1 -q:v 2 "$OUTPUT-grid.jpg"

# Auto-pick a "good" thumbnail (high-info frame)
ffmpeg -y -i "$INPUT" -vf "thumbnail,scale=640:-1" -frames:v 1 "$OUTPUT.jpg"
```

`thumbnail` filter analyzes 100 frames and picks the most representative.

━━━

### 18 · Screen recording optimization

**When**: Convert a lossless screen capture (x264 -crf 0) to a shareable MP4.

```bash
ffmpeg -y -i "$INPUT" \
  -c:v libx264 -crf 22 -preset slow \
  -profile:v high -level:v 4.0 -pix_fmt yuv420p \
  -c:a aac -b:a 128k \
  -movflags +faststart "$OUTPUT"
```

`-pix_fmt yuv420p` is mandatory for browser/QuickTime playback (some screen captures are `yuv444p` and silently fail to play). `-movflags +faststart` moves the moov atom to the file head for instant streaming.

━━━

### 19 · Vertical crop for social — 9:16 from 16:9

**When**: Repurpose horizontal content for TikTok / Reels / Shorts.

```bash
# Center crop to 9:16 (assumes 1920x1080 → 608x1080)
ffmpeg -y -i "$INPUT" -vf "crop=ih*9/16:ih" \
  -c:v libx264 -crf 22 -preset medium -c:a copy "$OUTPUT"

# Blurred background, original centered (full-frame 1080x1920 with cinematic look)
ffmpeg -y -i "$INPUT" -filter_complex "
  [0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=20:5[bg];
  [0:v]scale=1080:-2[fg];
  [bg][fg]overlay=(W-w)/2:(H-h)/2
" -c:v libx264 -crf 22 -preset medium -c:a copy "$OUTPUT"
```

The second pattern (blurred background) is the "Instagram standard" look — original aspect preserved with brand-color/blurred fill.

━━━

### 20 · Normalize audio levels — loudnorm

**When**: Multiple clips need consistent loudness (broadcast / podcast standard).

```bash
# Single-pass loudnorm (EBU R128 target -16 LUFS for streaming)
ffmpeg -y -i "$INPUT" -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
  -c:v copy -c:a aac -b:a 192k "$OUTPUT"

# Two-pass loudnorm (more accurate — measure then apply)
# Pass 1 — measure
ffmpeg -i "$INPUT" -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json -f null - 2> /tmp/loudnorm.log

# Read measured_I, measured_TP, measured_LRA, measured_thresh, offset from /tmp/loudnorm.log
# then pass 2:
ffmpeg -y -i "$INPUT" -af "loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=${MI}:measured_TP=${MTP}:measured_LRA=${MLRA}:measured_thresh=${MTH}:offset=${OFFSET}:linear=true:print_format=summary" \
  -c:v copy -c:a aac -b:a 192k "$OUTPUT"
```

Targets: `-16 LUFS` (Spotify/YouTube), `-14 LUFS` (Apple), `-23 LUFS` (EBU broadcast). `TP` = true peak ceiling, `LRA` = loudness range.

━━━

## Phase 3 — Execute

Run the selected ffmpeg command. Capture stdout/stderr. Common error patterns:

- **`No such file or directory`** → verify input path exists and is absolute
- **`Invalid argument`** → check filter syntax (especially escaped quotes inside `filter_complex`)
- **`Stream specifier '...' matches no streams`** → input has no audio (use `-an` or check `ffprobe`)
- **`could not find tag for codec`** → container doesn't support the codec, re-encode instead of stream copy
- **`height not divisible by 2`** → use `scale=W:-2` instead of `scale=W:-1`

For long renders (>30 s expected), recommend backgrounding the bash command and monitoring output.

━━━

## Phase 4 — Verify

After ffmpeg exits 0, run ffprobe on the output:

```bash
ffprobe -v quiet -print_format json -show_format -show_streams "$OUTPUT" | python3 -m json.tool

# Quick checks
ffprobe -v quiet -show_entries format=duration,size,bit_rate -of default=nw=1 "$OUTPUT"
ffprobe -v quiet -show_entries stream=codec_name,codec_type,width,height,r_frame_rate -of default=nw=1 "$OUTPUT"
```

Confirm:

- [ ] Duration matches expected (within ±0.5 s for trim/concat operations)
- [ ] Video codec / resolution matches request
- [ ] Audio codec present (or correctly absent for `-an` cases)
- [ ] File size is reasonable (flag if 10× expected — likely a config error)

For two-pass / size-targeted encodes, verify size is **at or below** the requested ceiling.

━━━

## Phase 5 — Store Output

Default destinations by output type:

| Output type | Default folder |
|-------------|----------------|
| Demo / highlight reel | `assets/demo/` |
| Screen recording | `assets/recordings/` |
| Thumbnail / poster | `assets/thumbnails/` |
| GIF | `assets/gifs/` |
| Extracted audio | `assets/audio/` |
| Subtitled version | `assets/subtitled/` |
| Social cut (9:16) | `assets/social/` |

Filename convention: `<topic>-<operation>-<YYYY-MM-DD>.<ext>` (e.g. `ckis-demo-cut-2026-05-29.mp4`). If [OWNER] provides a name, use it verbatim.

If the operation was a one-off command (not a saved script), no further action. If the operation will recur (e.g. weekly highlight reels), offer to save it as a script under `scripts/`.

━━━

## Report Format

```
━━━ Video Edit — {YYYY-MM-DD HH:MM} ━━━

Operation : {recipe name}
Input     : {path} ({size}, {duration}, {codec})
Output    : {path} ({size}, {duration}, {codec})
Recipe    : #{N} — {title}
Encode    : {CRF N preset X} or {two-pass ${kbps}k} or {stream copy}
Duration  : ffmpeg ran in {Ns}

Verify:
- Duration delta: {±s vs expected}
- Codec: {OK | MISMATCH}
- Size:  {actual vs target}
- Playback: {OK based on ffprobe} 

Stored at: {final path}
```

━━━

## Examples

**Example 1** — [OWNER] says "cut video $HOME/Videos/talk.mkv from 5:30 to 6:45":

- Phase 1: Operation = trim, Input = `$HOME/Videos/talk.mkv`, Output = `assets/demo/talk-cut-2026-05-29.mp4`, span = 5:30→6:45 (75 s).
- Phase 2: Recipe 2 (simple trim, precise — span doesn't need keyframe-snapping).
- Phase 3: `ffmpeg -y -i talk.mkv -ss 00:05:30 -to 00:06:45 -c:v libx264 -crf 20 -preset medium -c:a aac -b:a 128k assets/demo/talk-cut-2026-05-29.mp4`
- Phase 4: ffprobe — duration 75.04 s ✅, codec h264 ✅, size 18 MB ✅.
- Phase 5: Output stored. Report delivered.

**Example 2** — [OWNER] says "make a highlight reel from $HOME/Videos/ckis-demo.mkv: 16-63s, 80-100s, 190-223s":

- Phase 1: Operation = highlight-reel, Input = one source, 3 spans, total 100 s.
- Phase 2: Recipe 1 (filter_complex multi-clip).
- Phase 3: Builds the FILTER string with three `[vN]/[aN]` blocks and `concat=n=3:v=1:a=1`. Runs the ffmpeg command.
- Phase 4: ffprobe — duration 100.04 s ✅, H.264 high@4.0 ✅, AAC 128k ✅, size 11 MiB ✅.
- Phase 5: Output at `assets/demo/ckis-demo-cut.mp4`. Offers to save as `scripts/edit-ckis-demo-video.sh` for re-runs.

━━━

## Troubleshooting

**ffmpeg not found** → install: `sudo apt install ffmpeg` (Debian/Ubuntu), `brew install ffmpeg` (macOS), `winget install ffmpeg` (Windows). Verify with `ffmpeg -version`.

**Output plays but has no audio** → input might be variable-framerate or have multiple audio tracks. Run `ffprobe -i "$INPUT"` to inspect streams, then use `-map 0:v:0 -map 0:a:0` to explicitly select stream indices.

**"Too many packets buffered for output stream"** → mismatched stream timing. Add `-async 1` or `-vsync 1` to force sync. For severe drift, re-encode with `-r 30` to normalize framerate.

**Filter syntax errors with quotes** → in `filter_complex`, prefer single quotes for the outer wrapper and double quotes inside. Escape commas in filter args with `\,`. For multi-line filters, ensure no spaces around `;` separators.

**Two-pass produces wrong size** → check that pass 1 log file (`/tmp/ff2pass-0.log`) was created and is non-empty before pass 2. Pass 1 failure silently makes pass 2 fall back to single-pass behavior.

**Output won't play in browser** → likely missing `-pix_fmt yuv420p` (most browsers reject yuv444p) or `-movflags +faststart` (browser can't start streaming until moov atom is read). Always include both for web output.

**libx265 output massive** → x265 with default settings is verbose. Add `-preset slow -x265-params log-level=error` and lower CRF by 6 vs your x264 target.

**Concat without re-encode fails** → input files must share codec, resolution, framerate, pixel format, audio codec, audio sample rate. Check all with `ffprobe`. If any differ, use Recipe 1 (filter_complex concat) which re-encodes.

**Drawtext "Cannot find a valid font"** → install the font or specify full path with `fontfile=`. Common Linux fonts at `/usr/share/fonts/truetype/dejavu/`.

━━━

## QA Checklist

The skill run is complete when:

- [ ] Operation type identified and confirmed with [OWNER] (if ambiguous)
- [ ] Correct recipe selected from library (or hybrid built from documented patterns)
- [ ] ffmpeg command executed with exit code 0
- [ ] Output file exists at expected path
- [ ] ffprobe verification passed (duration, codec, size all within tolerance)
- [ ] No source file modified or overwritten
- [ ] No `.obsidian/` modifications
- [ ] Report delivered with input/output stats + verify results
- [ ] If operation is recurring, offered to save as a script under `scripts/`
