#!/bin/bash
# Generates placeholder pronunciation audio (macOS `say` TTS) for every word in
# BabyFirstWords/Resources/lessons.json, into Resources/Audio/en and Resources/Audio/es.
# Re-run any time lessons.json changes. Replace individual .m4a files later with
# real recordings at the same paths — no code changes needed.
set -euo pipefail

cd "$(dirname "$0")/.."
JSON=BabyFirstWords/Resources/lessons.json
OUT_EN=BabyFirstWords/Resources/Audio/en
OUT_ES=BabyFirstWords/Resources/Audio/es
mkdir -p "$OUT_EN" "$OUT_ES"

EN_VOICE="Samantha"
ES_VOICE="Paulina"   # es_MX — Mexican Spanish, more natural than the multi-locale novelty voices

generate() {
  local voice="$1" text="$2" out="$3"
  local tmp
  tmp=$(mktemp /tmp/tts.XXXXXX.aiff)
  say -v "$voice" -o "$tmp" "$text"
  afconvert -f m4af -d aac "$tmp" "$out"
  rm -f "$tmp"
}

jq -c '.[].words[]' "$JSON" | while read -r word; do
  id=$(echo "$word" | jq -r '.word_id')
  en_text=$(echo "$word" | jq -r '.en_text')
  es_text=$(echo "$word" | jq -r '.es_text')
  echo "Generating audio for $id ($en_text / $es_text)"
  generate "$EN_VOICE" "$en_text" "$OUT_EN/$id.m4a"
  generate "$ES_VOICE" "$es_text" "$OUT_ES/$id.m4a"
done

echo "Done. Audio written to $OUT_EN and $OUT_ES"
