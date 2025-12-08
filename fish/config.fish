if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Aliases
alias mac 'ssh sypianski@100.110.74.7'
alias highlights 'ssh jakub@100.110.74.7 "cd ~/vultoj/vulto_de_sajeso && python3 highlight_importer.py"'
alias obsidian 'ssh jakub@100.110.74.7 "cd ~/vultoj/vulto && vim"'
alias vps 'ssh yaqub@188.166.23.122'
alias masawayh 'ssh yaqub@188.166.23.122'
alias cc 'claude --dangerously-skip-permissions'

# API keys (loaded from separate secure file)
if test -f "$HOME/.secrets"
    source "$HOME/.secrets"
end

# Theme switcher for Termux + tmux
function theme
    set -l themes_dir "$HOME/.termux/themes"
    set -l colors_file "$HOME/.termux/colors.properties"

    if test -z "$argv[1]"
        echo "Available themes:"
        for f in $themes_dir/*.properties
            basename "$f" .properties
        end
        echo "  nocolors"
        echo ""
        echo "Usage: theme <name>"
        return
    end

    # Handle nocolors pseudo-theme
    if test "$argv[1]" = "nocolors"
        # Monochromatic - disable colors in terminal
        printf '\033]10;#000000\007'  # foreground
        printf '\033]11;#FFFFFF\007'  # background
        # Update tmux for light monochrome
        if set -q TMUX
            tmux set -g status-bg white
            tmux set -g status-fg black
            tmux set -g message-style "bg=white,fg=black"
            tmux set -g pane-border-style fg=black
            tmux set -g pane-active-border-style fg=black
        end
        echo "Switched to: nocolors (monochromatic)"
        return
    end

    set -l theme_file "$themes_dir/$argv[1].properties"

    if not test -f "$theme_file"
        echo "Theme '$argv[1]' not found."
        echo "Available themes:"
        for f in $themes_dir/*.properties
            basename "$f" .properties
        end
        echo "  nocolors"
        return 1
    end

    cp "$theme_file" "$colors_file"
    termux-reload-settings

    # Update tmux colors to match theme
    if set -q TMUX
        switch $argv[1]
            case 'eink' 'eink-soft' 'eink-color'
                # Light themes
                tmux set -g status-bg white
                tmux set -g status-fg black
                tmux set -g message-style "bg=white,fg=black"
                tmux set -g pane-border-style fg=black
                tmux set -g pane-active-border-style fg=black
            case 'dark'
                # Dark theme
                tmux set -g status-bg '#1a1a1a'
                tmux set -g status-fg '#d4d4d4'
                tmux set -g message-style "bg=#1a1a1a,fg=#d4d4d4"
                tmux set -g pane-border-style fg='#4a4a4a'
                tmux set -g pane-active-border-style fg='#808080'
        end
    end

    echo "Switched to theme: $argv[1]"
end
fish_hybrid_key_bindings

# Auto-start tmux
if status is-interactive
    and not set -q TMUX
    tmux attach || tmux new
end
