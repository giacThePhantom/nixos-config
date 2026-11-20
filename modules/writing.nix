# Papers and theses: references, notes and the lab notebook, document
# conversion and PDF tools. The writing itself (LaTeX, Typst, Quarto) is set
# up per project: `dvt latex`, `dvt typst`. Fonts that stand in for Word's are
# in theme/gtk.nix.
{ config, ... }:
let
  inherit (config) settings;
in
{
  flake.modules.homeManager.writing =
    { lib, pkgs, ... }:
    {
      # References in the terminal: papis keeps each paper as a folder (PDF +
      # info.yaml) under ~/Documents/papers, plain files you can sync or put
      # in git. `papis add --from doi 10.1038/...` (or arxiv, a PDF...),
      # `papis open`, `papis export --all --format bibtex > refs.bib` for
      # LaTeX/Typst/Quarto. Instead of Zotero, whose nixpkgs build uses an
      # end-of-life Firefox engine.
      programs.papis = {
        enable = true;
        settings = {
          picktool = "fzf";
          # Citation keys like smith2021, the usual BibTeX style
          ref-format = "{doc[author_list][0][family]}{doc[year]}";
          # Folders named like li2009-the-sequence-alignment-map-format, not a hash
          add-folder-name = "{doc[author_list][0][family]}{doc[year]}-{doc[title]}";
        };
        libraries.papers = {
          isDefault = true;
          settings.dir = "~/Documents/Papers";
        };
      };

      # Notes and the lab notebook: zk keeps plain Markdown files in
      # ~/Documents/notes, linked to each other ([[...]]), found with fzf.
      # `zk journal` opens today's lab notebook entry, `zk paper li2009` the
      # notes on a paper (papis citation key), `zk edit -i` finds any note.
      programs.zk = {
        enable = true;
        settings = {
          notebook.dir = "~/Documents/notes";
          note = {
            language = "en";
            filename = "{{slug title}}";
            extension = "md";
            template = "default.md";
          };
          extra.author = settings.user.fullName;
          group.journal = {
            paths = [ "journal" ];
            note.filename = "{{format-date now '%Y-%m-%d'}}";
            note.template = "journal.md";
          };
          group.papers = {
            paths = [ "papers" ];
            note.filename = "{{extra.key}}";
            note.template = "paper.md";
          };
          format.markdown.link-format = "wiki";
          tool.fzf-preview = "bat -p --color always {-1}";
          alias = {
            journal = ''zk new --no-input --group journal "$ZK_NOTEBOOK_DIR/journal"'';
            paper = ''zk-paper "$1"''; # scripts/zk-paper.sh: details from papis
            recent = "zk edit --interactive --sort modified- --modified-after 'two weeks ago'";
          };
        };
      };
      xdg.configFile = {
        "zk/templates/default.md".text = ''
          # {{title}}

          {{content}}
        '';
        # A lab notebook entry: what was done, why, what came out (rule:
        # write decisions down, docs/14-good-practice.md)
        "zk/templates/journal.md".text = ''
          # {{format-date now "%A %d %B %Y"}}

          ## Done

          ## Decisions (and why)

          ## Next
        '';
        # {{content}}: authors, journal and DOI, piped in by zk-paper
        "zk/templates/paper.md".text = ''
          # {{title}}

          {{#if content}}
          {{content}}

          {{/if}}
          Reference: `papis open {{extra.key}}`, cite as [@{{extra.key}}]

          ## In one sentence

          ## Methods worth remembering

          ## Relevant to my work
        '';
      };
      # Neovim talks to zk's language server in the notes (link completion,
      # following links, backlinks): set up in the Neovim repository

      # zk needs its notebook (.zk inside) and the groups' folders to exist
      home.activation.zkNotebook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/Documents/notes/.zk" "$HOME/Documents/notes/journal" "$HOME/Documents/notes/papers"
      '';

      home.packages = with pkgs; [
        pandoc # Markdown, LaTeX, docx, HTML... into each other
        poppler-utils # pdftotext, pdfunite, pdfseparate, pdfinfo, pdfimages
        # Writing on PDFs: scanned forms, a handwritten signature, notes on a
        # draft. (Real form fields: open the PDF in Firefox, fill, save.)
        xournalpp
      ];
    };
}
