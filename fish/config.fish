if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Add pipx binaries to PATH
fish_add_path ~/.local/bin

# Aliases
alias mac 'ssh sypianski@100.110.74.7'
alias highlights 'ssh jakub@100.110.74.7 "cd ~/vultoj/vulto_de_sajeso && python3 highlight_importer.py"'
alias obsidian 'ssh jakub@100.110.74.7 "cd ~/vultoj/vulto && vim"'
alias vps 'ssh yaqub@188.166.23.122'
alias masawayh 'ssh yaqub@188.166.23.122'
alias cc 'claude --dangerously-skip-permissions'
alias corne42 '~/klavaro/zmk/flash.sh'
alias rikargar 'source ~/fish/config.fish'  # reload config
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
            systemctl --user is-active syncthing
        case '*'
            echo "Usage: sync [on|off|status]"
    end
end

# Funkcja do wstawiania komendy attach (musi być zdefiniowana globalnie)
function _vps_tmux_attach --on-event fish_prompt
    if set -q __vps_attach_pending
        set -e __vps_attach_pending
        functions -e _vps_tmux_attach
        commandline -i 'tmux attach -t '
    end
end

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
if status is-interactive
    and not set -q TMUX
    if test (hostname) = "masawayh"
        # VPS: muntar nubi se ne ja muntita
        if not set -q __nubi_muntita
            set -g __nubi_muntita 1
            __auto_muntar_nubi 2>/dev/null &
        end
        # VPS: startar monitor-sesiono kun btop (se ne ekzistas)
        if not tmux has-session -t monitor 2>/dev/null
            tmux new-session -d -s monitor btop
        end
        # VPS: preparar attach-komando
        set -g __vps_attach_pending 1
    else
        # Lokale: auto-attach a sesiono main
        tmux attach -dt main || tmux new -s main
    end
end

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
    # Historio por grafiki (maxime 30 valoroj)
    set -g __cpu_historio
    set -g __ram_historio
    set -l bloki "▁▂▃▄▅▆▇█"

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
        if test (count $__cpu_historio) -gt 30
            set __cpu_historio $__cpu_historio[2..-1]
            set __ram_historio $__ram_historio[2..-1]
        end

        # Titolo
        echo
        echo "$cyan══════════ GLUTONI-VIDO ══════════$norm"
        echo

        # CPU grafiko
        set -l cpu_graph ""
        for val in $__cpu_historio
            set -l idx (math "round($val / 12.5) + 1")
            test $idx -lt 1; and set idx 1
            test $idx -gt 8; and set idx 8
            set cpu_graph "$cpu_graph"(string sub -s $idx -l 1 $bloki)
        end
        set -l cpu_color $norm
        test $cpu_percent -ge 80; and set cpu_color $red
        test $cpu_percent -ge 50 -a $cpu_percent -lt 80; and set cpu_color $yellow
        printf "$cyan%s$norm %s %s%3d%%$norm\n" "procesoro:" "$dim$cpu_graph$norm" $cpu_color $cpu_percent

        # RAM grafiko
        set -l ram_graph ""
        for val in $__ram_historio
            set -l idx (math "round($val / 12.5) + 1")
            test $idx -lt 1; and set idx 1
            test $idx -gt 8; and set idx 8
            set ram_graph "$ram_graph"(string sub -s $idx -l 1 $bloki)
        end
        set -l ram_color $norm
        test $mem_avail -lt 512; and set ram_color $red
        test $mem_avail -lt 1024 -a $mem_avail -ge 512; and set ram_color $yellow
        set -l mem_avail_gb (printf "%.1f" (math "$mem_avail / 1024"))
        set -l mem_total_gb (printf "%.1f" (math "$mem_total / 1024"))
        printf "$cyan%s$norm     %s %s%3d%%$norm  $dim($mem_avail_gb/$mem_total_gb g libera)$norm\n" "memoro:" "$dim$ram_graph$norm" $ram_color $mem_percent

        # Permuto (swap)
        set -l swap_info (free -m | awk '/^Swap:/ {printf "%d %d", $3, $2}')
        set -l swap_used (echo $swap_info | awk '{print $1}')
        set -l swap_total (echo $swap_info | awk '{print $2}')
        if test $swap_total -gt 0
            set -l swap_gb (printf "%.1f/%.1f" (math "$swap_used / 1024") (math "$swap_total / 1024"))
            printf "$cyan%s$norm     %sg\n" "permuto:" $swap_gb
        end

        echo
        echo "$cyan─────────── PROCESI ───────────$norm"
        printf " $dim  %-14s %4s %4s %6s$norm\n" "NOMO" "RAM" "CPU" "PID"

        # Procesi (reuzar logiko de glutoni)
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
                        set name "claude:$sess"
                        break
                    end
                end
            end
            set name (string sub -l 14 $name)

            set -l color $norm
            if test $ram -ge 10 -o $cpu -ge 50
                set color $red
            else if test $ram -ge 5 -o $cpu -ge 20
                set color $yellow
            end

            printf " $cyan$proc_num$norm$color %-14s %3s%% %3s%% %6s$norm\n" $name $ram $cpu $pid
        end

        # Detektar mortinta claude-rg (0% CPU, uzas RAM)
        set -l dead_rg (ps -eo pid,%cpu,cmd --no-headers | grep -E 'claude.*rg|\.local/share/claude/versions' | grep -v grep | grep -cE '^\s*[0-9]+\s+0\.0\s')
        if test $dead_rg -ge 2
            echo
            echo "$yellow⚠ $dead_rg mortinta claude-rg procesi detektita$norm"
            echo "$dim  cleanup-claude-rg  # ocidar manuale$norm"
        end

        echo
        echo $dim"[1-8] ocidar procesin  [q] elir  [Enter] refreŝigar"$norm

        # Atendi enigon aŭ timeout
        set -l input_key ""
        read -n 1 -t 10 input_key 2>/dev/null

        # Procesi enigon
        if test "$input_key" = "q"
            echo "Ĝis revido!"
            break
        else if string match -qr '^[1-8]$' "$input_key"
            set -l kill_idx $input_key
            if test $kill_idx -le (count $__gv_pids)
                set -l kill_pid $__gv_pids[$kill_idx]
                kill $kill_pid 2>/dev/null
                echo "$red""Ocidita PID $kill_pid$norm"
                sleep 1
            end
        end
        # Alie (Enter aŭ timeout): simple refreŝigar
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
                        set name "claude:$sess"
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
        case '*'
            echo "t - tmux rapida komandi"
            echo ""
            echo "  t a [nomo]  - atar a sesiono"
            echo "  t n [nomo]  - nova sesiono"
            echo "  t k [nomo]  - kilar sesiono"
            echo "  t l         - listar sesioni"
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

    # Centered title
    set -l title "۩ MASAWAYH ۩"
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
    set -l cc_count (pgrep -fc 'claude.*--dangerously-skip-permissions' 2>/dev/null; or echo 0)

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

    # Averto (nur se problemo)
    if test $ram_problem -eq 1
        echo "$red""⚠ RAM malalta!$norm"
    end

    # Bottom border
    echo "╰"(string repeat -n $width "─")"╯"
end
