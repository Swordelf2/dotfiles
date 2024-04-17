function help
    if count $argv
        $argv --help | bat --plain --language=help
    else
        echo "Usage: help [COMMAND]"
    end
end
