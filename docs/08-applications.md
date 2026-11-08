# Applications

## What's installed

| App | For | Open with |
| --- | --- | --- |
| Firefox | the web | `Super + B` |
| Betterbird | email, also university and Gmail accounts (a fine-tuned Thunderbird) | launcher; email links |
| renCal | calendar (Google, Microsoft, CalDAV) | launcher; events also in `Super + C` |
| Spotify | music, in the system's colours | `Super + Shift + M` |
| mpv | video and audio files | opening a file |
| imv | images | opening a file |
| zathura | PDFs, with dark pages (`Ctrl + R`: original colours; `J/K` scroll, `/` search) | opening a file |
| Thunar | files: tabs, split view (`F3`), trash, USB drives, thumbnails; right click to extract or compress archives, or open a terminal or lf there | `Super + E`; opening a folder |
| lf | files, in the terminal ([its keys](07-terminal.md#lf)) | `Super + Alt + E`; `lf` |
| volume mixer | per-app volume, speakers and microphones | `Super + P` |
| bluetui | Bluetooth: pair and connect devices | *Super + Space > Setup > Bluetooth* |

Files open in the right app by themselves: PDFs in zathura, images in imv,
videos in mpv, web links in Firefox, email links and `.eml` files in
Betterbird, folders in Thunar.

Betterbird keeps your mail and settings in `~/.config/thunderbird` (back
that folder up to keep them) and comes with the system's updates, not its
own. A Google account (your university one included) needs only its
address: Betterbird recognises it and opens Google's own sign-in window.

## Optional apps

Bigger apps are switched off by default, so nobody pays for what they don't
use. To add one, put its name in the list in `modules/hosts/nixos/default.nix`
(the comment there lists them) and `rebuild`.

| Name | What | Size |
| --- | --- | --- |
| `office` | OnlyOffice: the closest to Microsoft Office; .docx, .xlsx, .pptx keep their layout, tracked changes and comments work | +1.3 GiB |
| `libreoffice` | LibreOffice, instead of `office`, if you want Zotero's citations inside your documents | +1.7 GiB |
| `igv` | IGV, the genome browser | +640 MiB |
| `pymol` | PyMOL, protein structures | +300 MiB |
| `inkscape` | Inkscape, to finish figures and posters (SVG, PDF) | +500 MiB |
| `containers` | Podman (Docker images, `docker` works) and Apptainer (your cluster's images), on your computer (this one goes in the first list, `nixos`) | +510 MiB |
| `backup` | nightly encrypted backups of your documents and projects (see [Research tools](09-research.md#backups)) | small |
| `syncthing` | keep folders in sync between your computers, no cloud | +30 MiB |
| `sioyek` | a PDF viewer made for papers, which becomes the default for PDFs (see [Research tools](09-research.md#reading-papers)) | +300 MiB |
| `accessibility` | the Orca screen reader, a magnifier (`Super + Alt + Z`), larger text and cursor (this one goes in both lists) | +760 MiB |

Something else? See [Making it yours](11-making-it-yours.md#adding-software),
or run it once with `, name` (see [Projects](10-projects.md)).

## Gaming

Steam and Lutris are installed. Both download what they need to run Windows
games (Proton, Wine) the first time.

- **Steam:** install and play. For a Windows-only game: *Properties >
  Compatibility*, force a Proton version. Add `gamemoderun %command%` to a
  game's launch options for a performance boost.
- **EA, GOG, Battle.net games** go through Lutris: press `+` > *Search the
  Lutris website for installers*, pick the store (e.g. **EA App**), log in,
  and install your games from inside it.
- **Keep games in your home folder** (or on another Linux-formatted drive),
  not on a Windows (NTFS) drive: Wine needs Linux file permissions.
- **Games that use the Super key:** `Super + F11` sends every key to the
  game; press it again to get your keys back.

Next: [Research tools](09-research.md).
