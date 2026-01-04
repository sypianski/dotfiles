function klavi --description "Toggle Termux extra keys (esc, ctrl, alt, etc.)"
    set -l props ~/.termux/termux.properties
    set -l keys_on 'extra-keys = [["ESC","TAB","CTRL","ALT",{key: "-", popup: "|"},"DOWN","UP"]]'
    set -l keys_off 'extra-keys = []'

    if not test -f $props
        echo "Brak pliku $props"
        return 1
    end

    if grep -q 'extra-keys = \[\]' $props
        # Currently off -> turn on
        sed -i 's/extra-keys = \[\]/'"$keys_on"'/' $props
        echo "Extra keys: ON"
    else
        # Currently on -> turn off
        sed -i 's/^extra-keys = .*/'"$keys_off"'/' $props
        echo "Extra keys: OFF"
    end

    termux-reload-settings
end
