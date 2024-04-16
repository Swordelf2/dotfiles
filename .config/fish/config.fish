if status is-interactive
    starship init fish | source
    # Commands to run in interactive sessions can go here
    fish_vi_key_bindings
    source "$XDG_CONFIG_HOME/shell/aliasrc"
end
