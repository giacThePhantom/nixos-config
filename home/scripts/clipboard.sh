# clipboard: pick an entry from the clipboard history and copy it again
cliphist list | fuzzel --dmenu --prompt "󰅌  " | cliphist decode | wl-copy
