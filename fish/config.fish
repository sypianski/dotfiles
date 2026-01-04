if status is-interactive
    # Commands to run in interactive sessions can go here

    # Auto-sync dotfiles (background, every shell start)
    if test -d ~/dotfiles/.git
        fish -c '
            git -C ~/dotfiles fetch --quiet 2>/dev/null
            set -l local_head (git -C ~/dotfiles rev-parse HEAD 2>/dev/null)
            set -l remote_head (git -C ~/dotfiles rev-parse "@{u}" 2>/dev/null)
            if test "$local_head" != "$remote_head"
                if not git -C ~/dotfiles status --porcelain 2>/dev/null | string length -q
                    git -C ~/dotfiles pull --quiet 2>/dev/null
                end
            end
        ' &
        disown
    end
end

# Add pipx binaries to PATH
fish_add_path ~/.local/bin

# Aliases
alias mac 'ssh sypianski@100.110.74.7'
alias highlights 'ssh jakub@100.110.74.7 "cd ~/vulti/vulto_de_sajeso && python3 highlight_importer.py"'
alias obsidian 'ssh jakub@100.110.74.7 "cd ~/vulti/vulto && vim"'
alias vps 'ssh yaqub@188.166.23.122'
alias masawayh 'ssh yaqub@188.166.23.122'
alias cc 'claude --dangerously-skip-permissions'
alias corne42 '~/klavaro/zmk/flash.sh'
function rikargar  # reload fish + tmux config
    source ~/.config/fish/config.fish
    if set -q TMUX
        tmux source-file ~/.tmux.conf
        echo "Fish + tmux reloaded"
    else
        echo "Fish reloaded"
    end
end
alias muntar-gdrive 'rclone mount gdrive: ~/mnt/gdrive --vfs-cache-mode full --daemon'
alias muntar-dropbox 'rclone mount dropbox: ~/mnt/dropbox --vfs-cache-mode full --daemon'

# Glutinar el tondilo de Android a tmux
function tondilo-glutinar
    termux-clipboard-get | tmux load-buffer -
    tmux paste-buffer
end
alias cbr 'tondilo-glutinar'  # backward compat

# API keys (loaded from separate secure file)
if test -f "$HOME/.secrets"
    source "$HOME/.secrets"
end

# Temo-shanjar por Termux + tmux
function temo
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

# fish-ai keybinding for hybrid mode
bind -M insert \ea _fish_ai_autocomplete_or_fix
bind \ea _fish_ai_autocomplete_or_fix

# Syncthing toggle por vault sync
function sinkronigar
    switch $argv[1]
        case on
            systemctl --user start syncthing
            echo "Real-time sync ON"
        case off
            systemctl --user stop syncthing
            echo "Syncthing paused - using git"
        case status
            systemctl --user status syncthing
        case restart r
            systemctl --user restart syncthing
            echo "Syncthing restarted"
        case '*'
            echo "Usage: sinkronigar [on|off|status|restart]"
    end
end
alias sync 'sinkronigar'  # szybki alias

# sync-status: sprawdź stan synchronizacji
function sync-status
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l cyan (set_color cyan)
    set -l norm (set_color normal)

    echo "$cyan══════ Sync Status ══════$norm"

    # GDrive mount
    echo -n "GDrive:   "
    if mountpoint -q ~/mnt/gdrive 2>/dev/null
        echo "$green""OK$norm"
    else
        echo "$red""NOT MOUNTED$norm (muntar-gdrive)"
    end

    # Syncthing
    echo -n "Syncthing: "
    if systemctl --user is-active syncthing >/dev/null 2>&1
        echo "$green""ON$norm"
    else
        echo "$yellow""OFF$norm (sync on)"
    end

    echo "$cyan────── Foldery ──────$norm"

    # vault1
    echo -n "vault1:   "
    if test -d ~/vulti/vault1 -a -r ~/vulti/vault1
        set -l count (ls ~/vulti/vault1 2>/dev/null | wc -l)
        echo "$green""OK$norm ($count items)"
    else
        echo "$red""NIEDOSTĘPNY$norm"
    end

    # klavari
    echo -n "klavari:  "
    if test -d ~/klavari -a -r ~/klavari
        set -l count (ls ~/klavari 2>/dev/null | wc -l)
        echo "$green""OK$norm ($count items)"
    else
        echo "$red""NIEDOSTĘPNY$norm"
    end

    # projekti
    echo -n "projekti: "
    if test -d ~/projekti -a -r ~/projekti
        set -l count (ls ~/projekti 2>/dev/null | wc -l)
        echo "$green""OK$norm ($count items)"
    else
        echo "$red""NIEDOSTĘPNY$norm"
    end

    # sajeco (Syncthing)
    echo -n "sajeco:   "
    if test -d ~/vulti/sajeco
        echo "$green""OK$norm (ST)"
    else
        echo "$red""BRAK$norm"
    end

    # sse1k (Syncthing)
    echo -n "sse1k:    "
    if test -d ~/vulti/sse1k
        echo "$green""OK$norm (ST)"
    else
        echo "$red""BRAK$norm"
    end
end
alias ss 'sync-status'

# Auto-muntar nubo-diski (nur sur VPS, nur unfoye)
function __auto_muntar_nubi
    # gdrive
    if not mountpoint -q ~/mnt/gdrive 2>/dev/null
        rclone mount gdrive: ~/mnt/gdrive --vfs-cache-mode full --daemon &
    end
    # dropbox
    if not mountpoint -q ~/mnt/dropbox 2>/dev/null
        rclone mount dropbox: ~/mnt/dropbox --vfs-cache-mode full --daemon &
    end
end

# Auto-start tmux (diferanta konduto sur VPS vs lokale)
# Malŝaltita - uzanto povas mane ruli: tmux attach || tmux new -s main
# if status is-interactive
#     and not set -q TMUX
#     if string match -q '*masawayh*' (hostname)
#         # VPS: muntar nubi se ne ja muntita
#         if not set -q __nubi_muntita
#             set -g __nubi_muntita 1
#             __auto_muntar_nubi 2>/dev/null &
#         end
#         # VPS: startar monitor-sesiono kun btop (se ne ekzistas)
#         if not tmux has-session -t monitor 2>/dev/null
#             tmux new-session -d -s monitor btop
#         end
#         # VPS: nur montrar saluto, uzanto elektas sesion
#     else
#         # Lokale: auto-attach a sesiono main
#         tmux attach -dt main || tmux new -s main
#     end
# end

# ccusage - monitoring tokenów Claude Code
alias ccu='ccusage'
alias ccul='ccusage blocks --live'
alias ccub='ccusage blocks'
alias ccum='ccusage monthly'
alias ccud='ccusage daily'
alias ccm='claude-monitor --plan max5 --timezone Europe/Rome'

# Claude Code session management (Ido)
function claude-ocidar  # ocidar = kill
    set -l count (pgrep -fc 'claude.*--dangerously-skip-permissions' 2>/dev/null; or echo 0)
    if test $count -gt 0
        pkill -f 'claude.*--dangerously-skip-permissions'
        echo "Ocidis $count Claude Code sesiono(j)"
    else
        echo "Nula aktiva Claude Code sesioni"
    end
end

function claude-kontar  # kontar = count
    pgrep -fc 'claude.*--dangerously-skip-permissions' 2>/dev/null; or echo 0
end

# claude-videz: show Claude sessions with RAM % and tmux window (videz = see)
function claude-videz
    set -l pids (pgrep -f 'claude.*--dangerously-skip-permissions' 2>/dev/null)
    if test (count $pids) -eq 0
        echo "Nula sesioni de Claude Code"
        return
    end

    set -l cyan (set_color cyan)
    set -l norm (set_color normal)

    echo $cyan"Claude Code sesioni:"$norm
    for pid in $pids
        # Get RAM %
        set -l mem (ps -p $pid -o %mem= 2>/dev/null | string trim)

        # Find tmux window - check all panes for this PID or its children
        set -l tmux_info ""
        for pane in (tmux list-panes -a -F '#{pane_pid} #{session_name}:#{window_index}' 2>/dev/null)
            set -l pane_pid (echo $pane | awk '{print $1}')
            set -l pane_loc (echo $pane | awk '{print $2}')
            # Check if our claude process is descendant of this pane
            if pgrep -P $pane_pid -f 'claude.*--dangerously-skip-permissions' 2>/dev/null | grep -q $pid
                set tmux_info $pane_loc
                break
            end
            # Or if pane_pid itself matches
            if test "$pane_pid" = "$pid"
                set tmux_info $pane_loc
                break
            end
        end

        if test -z "$tmux_info"
            set tmux_info "?"
        end

        printf "  PID %s │ RAM %s%% │ tmux %s\n" $pid $mem $tmux_info
    end
end

# saluto: montrar la saluto (sen tmux-kontrolo)
function saluto
    set -e TMUX
    fish_greeting
end

# glutoni-vido: kontinua monitoro kun grafiki (vido = view)
function glutoni-vido
    # Historio por grafiki
    set -g __cpu_historio
    set -g __ram_historio
    set -l bloki "▁▂▃▄▅▆▇█"
    set -l graph_width 28

    while true
        clear
        set -l cyan (set_color cyan)
        set -l norm (set_color normal)
        set -l red (set_color -o red)
        set -l yellow (set_color yellow)
        set -l dim (set_color brblack)

        # Kolektar CPU e RAM
        set -l cpu_percent (awk '/^cpu / {usage=100-($5*100/($2+$3+$4+$5+$6+$7+$8))} END {printf "%.0f", usage}' /proc/stat)
        set -l mem_info (free -m | awk '/^Mem:/ {printf "%d %d %d", $3, $2, $7}')
        set -l mem_used (echo $mem_info | awk '{print $1}')
        set -l mem_total (echo $mem_info | awk '{print $2}')
        set -l mem_avail (echo $mem_info | awk '{print $3}')
        set -l mem_percent (math "round($mem_used * 100 / $mem_total)")

        # Aktualigar historio
        set -a __cpu_historio $cpu_percent
        set -a __ram_historio $mem_percent
        if test (count $__cpu_historio) -gt $graph_width
            set __cpu_historio $__cpu_historio[2..-1]
            set __ram_historio $__ram_historio[2..-1]
        end

        # Titolo (50 znaków)
        echo
        echo "$cyan═══════════════════ GLUTONI ════════════════════$norm"

        # CPU grafiko
        set -l cpu_graph ""
        set -l start_idx 1
        if test (count $__cpu_historio) -gt $graph_width
            set start_idx (math (count $__cpu_historio) - $graph_width + 1)
        end
        for i in (seq $start_idx (count $__cpu_historio))
            set -l val $__cpu_historio[$i]
            set -l idx (math "round($val / 12.5) + 1")
            test $idx -lt 1; and set idx 1
            test $idx -gt 8; and set idx 8
            set cpu_graph "$cpu_graph"(string sub -s $idx -l 1 $bloki)
        end
        while test (string length $cpu_graph) -lt $graph_width
            set cpu_graph " $cpu_graph"
        end
        set -l cpu_color $norm
        test $cpu_percent -ge 80; and set cpu_color $red
        test $cpu_percent -ge 50 -a $cpu_percent -lt 80; and set cpu_color $yellow
        set -l load (awk '{printf "%.1f", $1}' /proc/loadavg)
        printf "$cyan%s$norm %s %s%2d%%$norm $dim%s$norm\n" "cpu" "$cpu_graph" $cpu_color $cpu_percent $load

        # RAM grafiko
        set -l ram_graph ""
        set start_idx 1
        if test (count $__ram_historio) -gt $graph_width
            set start_idx (math (count $__ram_historio) - $graph_width + 1)
        end
        for i in (seq $start_idx (count $__ram_historio))
            set -l val $__ram_historio[$i]
            set -l idx (math "round($val / 12.5) + 1")
            test $idx -lt 1; and set idx 1
            test $idx -gt 8; and set idx 8
            set ram_graph "$ram_graph"(string sub -s $idx -l 1 $bloki)
        end
        while test (string length $ram_graph) -lt $graph_width
            set ram_graph " $ram_graph"
        end
        set -l ram_color $norm
        test $mem_avail -lt 512; and set ram_color $red
        test $mem_avail -lt 1024 -a $mem_avail -ge 512; and set ram_color $yellow
        set -l mem_avail_gb (printf "%.1f" (math "$mem_avail / 1024"))
        printf "$cyan%s$norm %s %s%2d%%$norm $dim%sg$norm\n" "ram" "$ram_graph" $ram_color $mem_percent $mem_avail_gb

        echo
        # Swap (z paskiem 28 znaków)
        set -l swap_info (free -m | awk '/^Swap:/ {printf "%d %d", $3, $2}')
        set -l swap_used (echo $swap_info | awk '{print $1}')
        set -l swap_total (echo $swap_info | awk '{print $2}')
        if test $swap_total -gt 0
            set -l swap_pct (math "round($swap_used * 100 / $swap_total)")
            set -l swap_filled (math "round($swap_pct * $graph_width / 100)")
            set -l swap_bar ""
            for i in (seq 1 $graph_width)
                if test $i -le $swap_filled
                    set swap_bar "$swap_bar▪"
                else
                    set swap_bar "$swap_bar·"
                end
            end
            set -l swap_color $norm
            test $swap_pct -ge 50; and set swap_color $yellow
            test $swap_pct -ge 80; and set swap_color $red
            set -l swap_gb (printf "%.1f" (math "$swap_used / 1024"))
            printf "$cyan%s$norm %s %s%2d%%$norm $dim%sg$norm\n" "swp" $swap_bar $swap_color $swap_pct $swap_gb
        end

        # Disk (z paskiem 28 znaków)
        set -l disk_info (df / | awk 'NR==2 {print $3, $2, $4}')
        set -l disk_used (echo $disk_info | awk '{print $1}')
        set -l disk_total (echo $disk_info | awk '{print $2}')
        set -l disk_avail_h (df -h / | awk 'NR==2 {print $4}')
        set -l disk_pct (math "round($disk_used * 100 / $disk_total)")
        set -l disk_filled (math "round($disk_pct * $graph_width / 100)")
        set -l disk_bar ""
        for i in (seq 1 $graph_width)
            if test $i -le $disk_filled
                set disk_bar "$disk_bar▪"
            else
                set disk_bar "$disk_bar·"
            end
        end
        set -l disk_color $norm
        test $disk_pct -ge 80; and set disk_color $yellow
        test $disk_pct -ge 90; and set disk_color $red
        printf "$cyan%s$norm %s %s%2d%%$norm $dim%s$norm\n" "dsk" $disk_bar $disk_color $disk_pct $disk_avail_h

        echo
        echo "$cyan─────────────────── procesi ────────────────────$norm"
        printf "$dim  %-24s %5s %5s$norm\n" "" "ram" "cpu"

        # Procesi
        set -l tmux_map
        for pane in (tmux list-panes -a -F '#{pane_pid} #{session_name}:#{window_index}' 2>/dev/null)
            set -a tmux_map $pane
        end

        set -l procs (ps aux --sort=-%mem | awk 'NR>1 && ($4>=1 || $3>=1) {print $2, $4, $3, $11}' | grep -v -E '^[0-9]+ [0-9.]+ [0-9.]+ (ps|awk|grep)' | head -8)

        # Stokar PID-oj por interaga ocido
        set -g __gv_pids
        set -l proc_num 0

        for proc in $procs
            set proc_num (math $proc_num + 1)
            set -l pid (echo $proc | awk '{print $1}')
            set -a __gv_pids $pid
            set -l ram (echo $proc | awk '{printf "%.0f", $2}')
            set -l cpu (echo $proc | awk '{printf "%.0f", $3}')
            set -l rawcmd (echo $proc | awk '{print $4}')
            set -l name (basename $rawcmd)

            if string match -q "*claude/versions/*" $rawcmd
                set name "claude-rg"
            else if string match -qr '^[0-9.]+$' $name
                set name (dirname $rawcmd | xargs basename)
            end

            if string match -q "claude" $name
                for entry in $tmux_map
                    set -l pane_pid (echo $entry | awk '{print $1}')
                    if pgrep -P $pane_pid 2>/dev/null | grep -q "^$pid\$"
                        set -l sess (echo $entry | awk -F: '{print $1}' | awk '{print $2}')
                        if test -n "$sess"
                            set name "claude: $sess"
                        end
                        break
                    end
                end
            end
            set name (string sub -l 24 $name)

            set -l color $norm
            if test $ram -ge 10 -o $cpu -ge 50
                set color $red
            else if test $ram -ge 5 -o $cpu -ge 20
                set color $yellow
            end

            printf "$cyan%s$norm$color %-24s %4s%% %4s%%$norm\n" $proc_num $name $ram $cpu
        end

        # Detektar mortinta claude-rg
        set -l dead_rg (ps -eo pid,%cpu,cmd --no-headers | grep -E 'claude.*rg|\.local/share/claude/versions' | grep -v grep | grep -cE '^\s*[0-9]+\s+0\.0\s')
        if test $dead_rg -ge 2
            echo "$yellow⚠ $dead_rg dead rg$norm"
        end

        echo
        echo $dim"[1-8]kill [q]uit [r]efresh"$norm
        echo

        # Atendi enigon aŭ timeout (10s)
        set -l input_key (bash -c 'read -t 10 -n 1 -s key; echo $key')
        if test -n "$input_key"
            switch $input_key
                case q Q
                    break
                case 1 2 3 4 5 6 7 8
                    set -l kill_idx $input_key
                    if test $kill_idx -le (count $__gv_pids)
                        set -l kill_pid $__gv_pids[$kill_idx]
                        kill -9 $kill_pid 2>/dev/null
                        echo ""
                        echo "$red✗ Ocidita PID $kill_pid$norm"
                        sleep 1
                    end
                case r R
                    # Tuja refreŝigo
                    continue
            end
        end
        # Timeout: aŭtomata refreŝigo
    end
end

# glutoni: procesi sortita segun maxima problemo (RAM o CPU)
function glutoni
    set -l cyan (set_color cyan)
    set -l norm (set_color normal)
    set -l red (set_color -o red)
    set -l yellow (set_color yellow)

    # Memoro
    set -l mem_avail (free -m | awk '/^Mem:/ {print $7}')
    set -l mem_total (free -m | awk '/^Mem:/ {print $2}')
    set -l swap_used (free -m | awk '/^Swap:/ {print $3}')
    set -l swap_total (free -m | awk '/^Swap:/ {print $2}')

    set -l mem_avail_gb (printf "%.1f" (math "$mem_avail / 1024"))
    set -l mem_total_gb (printf "%.1f" (math "$mem_total / 1024"))
    set -l swap_used_gb (printf "%.1f" (math "$swap_used / 1024"))
    set -l swap_total_gb (printf "%.1f" (math "$swap_total / 1024"))

    # RAM color (red if <1GB available)
    if test $mem_avail -lt 1024
        set mem_color $red
    else
        set mem_color $norm
    end

    echo
    echo "$cyan""ram:$norm $mem_color$mem_avail_gb$norm/$mem_total_gb""g  $cyan""swap:$norm $swap_used_gb/$swap_total_gb""g"

    # Build tmux pid->session map for Claude processes
    set -l tmux_map
    for pane in (tmux list-panes -a -F '#{pane_pid} #{session_name}:#{window_index}' 2>/dev/null)
        set -a tmux_map $pane
    end

    # Get processes (>= 1% RAM or CPU), exclude ps/awk/grep
    set -l procs (ps aux --sort=-%mem | awk 'NR>1 && ($4>=1 || $3>=1) {print $2, $4, $3, $11}' | grep -v -E '^[0-9]+ [0-9.]+ [0-9.]+ (ps|awk|grep)' | head -8)

    if test (count $procs) -gt 0
        echo
        echo "--------------------------------"
        printf " %-14s %4s %4s %6s\n" "PROC" "RAM" "CPU" "PID"
        echo "--------------------------------"

        for proc in $procs
            set -l pid (echo $proc | awk '{print $1}')
            set -l ram (echo $proc | awk '{printf "%.0f", $2}')
            set -l cpu (echo $proc | awk '{printf "%.0f", $3}')
            set -l rawcmd (echo $proc | awk '{print $4}')
            # Extract clean command name
            set -l name (basename $rawcmd)
            # Handle special paths
            if string match -q "*claude/versions/*" $rawcmd
                set name "claude-rg"
            else if string match -qr '^[0-9.]+$' $name
                set name (dirname $rawcmd | xargs basename)
            end

            # Find tmux session for Claude processes
            if string match -q "claude" $name
                for entry in $tmux_map
                    set -l pane_pid (echo $entry | awk '{print $1}')
                    if pgrep -P $pane_pid 2>/dev/null | grep -q "^$pid\$"
                        set -l sess (echo $entry | awk -F: '{print $1}' | awk '{print $2}')
                        if test -n "$sess"
                            set name "claude: $sess"
                        end
                        break
                    end
                end
            end
            set name (string sub -l 14 $name)

            # Color based on usage
            set -l color $norm
            if test $ram -ge 10 -o $cpu -ge 50
                set color $red
            else if test $ram -ge 5 -o $cpu -ge 20
                set color $yellow
            end

            printf " $color%-14s %3s%% %3s%% %6s$norm\n" $name $ram $cpu $pid
        end

        echo "--------------------------------"
        echo
    end
end

# Aliasi por retrokompateso
alias memoro 'glutoni'
alias procesoro 'glutoni'
alias gv 'glutoni-vido'

# Recetageto - scraper przepisów z jadłonomia
alias recetageto '~/utensili/recetageto/.venv/bin/python ~/utensili/recetageto/scraper.py'

# mon: rapide irar a monitor-sesiono
function mon
    tmux switch-client -t monitor 2>/dev/null
    or tmux attach -t monitor 2>/dev/null
    or begin
        tmux new-session -d -s monitor btop
        tmux attach -t monitor
    end
end

# t: tmux rapida komandi
function t
    # Nula argumenti: startar/atar monitor-sesiono
    if test -z "$argv[1]"
        set -l sess mon
        if not tmux has-session -t $sess 2>/dev/null
            # Krear nova sesiono kun gv en fenestro 0
            tmux new-session -d -s $sess -n gv
            tmux send-keys -t $sess:gv gv Enter
        end
        # Atar aŭ ŝanĝi
        if set -q TMUX
            tmux switch-client -t $sess
        else
            tmux attach -t $sess
        end
        return
    end

    switch $argv[1]
        case a atar
            # Atar a sesiono (attach)
            if test -z "$argv[2]"
                # Listar sesioni se nula argumento
                echo "Sesioni:"
                tmux ls 2>/dev/null; or echo "  (nula)"
                echo ""
                commandline -i "tmux attach -t "
            else
                tmux attach -t $argv[2]
            end
        case n nova
            # Nova sesiono
            if test -z "$argv[2]"
                commandline -i "tmux new -s "
            else
                tmux new -s $argv[2]
            end
        case k kilar
            # Kilar sesiono
            if test -z "$argv[2]"
                echo "Sesioni:"
                tmux ls 2>/dev/null; or echo "  (nula)"
                echo ""
                commandline -i "tmux kill-session -t "
            else
                tmux kill-session -t $argv[2]
            end
        case l listar
            tmux ls
        case g grupi
            # Nova sesiono grupita kun ekzistanta
            if test -z "$argv[2]"
                echo "Sesioni:"
                tmux ls 2>/dev/null; or echo "  (nula)"
                echo ""
                commandline -i "t g "
            else
                # Krei grupitan sesion kun unika nomo
                set -l base $argv[2]
                set -l suffix 2
                set -l new_name "$base-$suffix"
                while tmux has-session -t $new_name 2>/dev/null
                    set suffix (math $suffix + 1)
                    set new_name "$base-$suffix"
                end
                tmux new-session -t $base -s $new_name
            end
        case h help
            echo "t - tmux rapida komandi"
            echo ""
            echo "  t           - startar/atar monitor (gv)"
            echo "  t a [nomo]  - atar a sesiono"
            echo "  t n [nomo]  - nova sesiono"
            echo "  t g [nomo]  - nova sesiono grupita"
            echo "  t k [nomo]  - kilar sesiono"
            echo "  t l         - listar sesioni"
        case '*'
            echo "Nekonata: $argv[1]. Uzu 't h' por helpo."
    end
end

# Welcome greeting (replaces default fish_greeting)
function fish_greeting
    # Only show outside tmux to avoid repetition in every pane
    if set -q TMUX
        return
    end

    set -l width 35
    set -l cyan (set_color -o cyan)
    set -l norm (set_color normal)

    # Centered title (zależny od serwera)
    set -l title "◆ "(hostname)" ◆"
    switch (hostname)
        case masawayh
            set title "۩ MASAWAYH ۩"
        case ibn-masawayh
            set title "۞ IBN MASAWAYH ۞"
    end
    set -l title_len (string length $title)
    set -l padding (string repeat -n (math --scale=0 "($width - $title_len) / 2") " ")

    # Memory (in MB for comparison)
    set -l mem_avail (free -m | awk '/^Mem:/ {print $7}')
    set -l mem_total (free -m | awk '/^Mem:/ {print $2}')
    set -l swap_used (free -m | awk '/^Swap:/ {print $3}')
    set -l swap_total (free -m | awk '/^Swap:/ {print $2}')

    # Format memory as GB
    set -l mem_avail_gb (printf "%.1f" (math "$mem_avail / 1024"))
    set -l mem_total_gb (printf "%.1f" (math "$mem_total / 1024"))
    set -l swap_used_gb (printf "%.1f" (math "$swap_used / 1024"))
    set -l swap_total_gb (printf "%.1f" (math "$swap_total / 1024"))

    # Color based on available RAM (<1GB = red, else green)
    if test $mem_avail -lt 1024
        set mem_color (set_color -o red)
    else
        set mem_color (set_color green)
    end

    # Claude sessions
    set -l cc_count (pgrep -fc 'claude.*--dangerously-skip-permissions' 2>/dev/null; or echo 0)[-1]

    # Tmux sessions (names only)
    set -l tmux_names
    for line in (tmux ls 2>/dev/null)
        set -l name (echo $line | cut -d: -f1)
        if string match -q '*attached*' $line
            set -a tmux_names (set_color -o)"$name"$norm
        else
            set -a tmux_names $name
        end
    end

    # Build tmux lines (wrap at width)
    set -l tmux_lines
    if test (count $tmux_names) -gt 0
        set -l current_line "$cyan"'tmux:'"$norm "
        set -l current_len 6  # "tmux: "
        set -l first 1
        for name in $tmux_names
            set -l name_plain (string replace -ra '\e\[[^m]*m' '' $name)
            set -l name_len (string length $name_plain)
            set -l sep_len 3  # " · "
            if test $first -eq 1
                set current_line "$current_line$name"
                set current_len (math "$current_len + $name_len")
                set first 0
            else if test (math "$current_len + $sep_len + $name_len") -le $width
                set current_line "$current_line · $name"
                set current_len (math "$current_len + $sep_len + $name_len")
            else
                set -a tmux_lines "$current_line"
                set current_line "      $name"
                set current_len (math "6 + $name_len")
            end
        end
        set -a tmux_lines "$current_line"
    end

    # Detektar problemi
    set -l ram_problem 0
    set -l red (set_color -o red)

    if test $mem_avail -lt 1024
        set ram_problem 1
    end


    # Top border
    echo "╭"(string repeat -n $width "─")"╮"

    # Titulo
    echo "$padding$cyan$title$norm"

    # Tmux sesioni
    for line in $tmux_lines
        echo $line
    end

    # Claude (sub tmux)
    if test $cc_count -gt 0
        echo "$cyan""claude:$norm "(set_color yellow)"$cc_count"$norm
    end

    # Separilo
    echo

    # RAM, swap
    echo "$cyan""ram:$norm $mem_color$mem_avail_gb$norm/$mem_total_gb""g  $cyan""swap:$norm $swap_used_gb/$swap_total_gb""g"

    # Sync status (kompakta)
    set -l gdrive_ok (mountpoint -q ~/mnt/gdrive 2>/dev/null; and echo 1; or echo 0)
    set -l st_ok (systemctl --user is-active syncthing >/dev/null 2>&1; and echo 1; or echo 0)

    echo -n "$cyan""sync:$norm "
    if test $gdrive_ok -eq 1 -a $st_ok -eq 1
        echo (set_color green)"OK"$norm
    else
        set -l issues
        test $gdrive_ok -eq 0; and set -a issues "gdrive"
        test $st_ok -eq 0; and set -a issues "ST"
        echo (set_color red)"⚠ "(string join ", " $issues)$norm
    end

    # Averto (nur se problemo)
    if test $ram_problem -eq 1
        echo "$red""⚠ RAM malalta!$norm"
    end

    # Bottom border
    echo "╰"(string repeat -n $width "─")"╯"
end
