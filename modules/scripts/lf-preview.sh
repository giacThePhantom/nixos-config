# lf-preview FILE WIDTH HEIGHT: lf's preview pane (modules/terminal.nix).
# Images as sixel (foot draws them), text and data files with colours,
# gzipped files (FASTQ, VCF...) and archives by their first lines, anything
# else as `file`'s one-line description. Exit 1 tells lf not to cache the
# preview: a sixel image has to be drawn again each time.
file="$1" width="$2" height="$3"

case "$(file -Lb --mime-type -- "$file")" in
  image/*)
    chafa -f sixel -s "${width}x${height}" --animate off --polite on -- "$file"
    exit 1
    ;;
  text/* | application/json | application/x-ndjson | application/xml | application/javascript | inode/x-empty)
    bat --color=always --style=plain --paging=never --line-range=":$height" -- "$file"
    ;;
  application/gzip | application/x-gzip)
    # head closing the pipe early is expected, not an error
    gzip -dc -- "$file" | head -n "$height" || true
    ;;
  application/zip | application/x-tar | application/x-7z-compressed | application/x-xz | application/x-bzip2 | application/zstd)
    bsdtar -tf "$file" | head -n "$height" || true
    ;;
  application/pdf)
    pdftotext -l 2 -layout -- "$file" - | head -n "$height" || true
    ;;
  *)
    file -Lb -- "$file"
    ;;
esac
