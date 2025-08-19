# Completion directory (fixed location)
COMP_DIR="${ZSH_CACHE_DIR}/completions"
mkdir -p "$COMP_DIR"

# Command definitions (name → generation command)
typeset -A COMP_COMMANDS=(
    rclone   "rclone completion zsh -"
    helm     "helm completion zsh"
    kubectl  "kubectl completion zsh"
    podman  "podman completion zsh"
    npm  "npm completion"
    pip  "pip completion --zsh"
    pipx  "register-python-argcomplete pipx"
)

# Generate completion if missing
generate-completion() {
    local cmd="$1"
    local gen_cmd="${COMP_COMMANDS[$cmd]}"
    local dest="$COMP_DIR/_$cmd"

    # Skip if command doesn't exist or file exists
    if ! (( $+commands[$cmd] )) || [[ -f "$dest" ]]; then
        return
    fi

    # Generate in background
    eval "$gen_cmd" >| "$dest" &|
    autoload -Uz "_$cmd"
}

# Generate all completions
generate-all-completions() {
    for cmd in "${(@k)COMP_COMMANDS}"; do
        generate-completion "$cmd"
    done
}

# Regenerate all completions (force update)
regen-completions() {
    for cmd in "${(@k)COMP_COMMANDS}"; do
        local dest="$COMP_DIR/_$cmd"
        [[ -f "$dest" ]] && rm -f "$dest"
        generate-completion "$cmd"
    done
    echo "Completions regenerated"
}

# Initial generation at plugin load
generate-all-completions
