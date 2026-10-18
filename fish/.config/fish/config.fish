if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source

    if not set -q TMUX
        tmux new-session
    end
end

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
