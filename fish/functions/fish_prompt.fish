function fish_prompt
    set -l icon "›"
    switch (hostname)
        case masawayh
            set icon "۩"
        case ibn-masawayh
            set icon "۞"
    end
    echo -n (set_color -o magenta)$icon(set_color normal)' '
end
