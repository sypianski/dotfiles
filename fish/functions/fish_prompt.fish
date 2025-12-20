function fish_prompt
    if set -q SSH_CLIENT
        echo 'masawayh > '
    else
        echo 'macOS > '
    end
end
