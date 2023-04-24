#!/bin/bash

create_symlink() {
    source=$1
    destination=$2
    if [ -L "$destination" ]; then
        read -p "Override existing symlink $destination? (y/N) " consent
        if [ "$consent" == "y" ] || [ "$consent" == "Y" ]; then
            rm "$destination"
            ln -s "$source" "$destination"
        fi
    elif [ -e "$destination" ]; then
        echo "Error: $destination already exists as a $(file "$destination" | awk '{print $2}')"
    else
        ln -s "$source" "$destination"
    fi
}

install_dotfiles() {
    dotfiles_repository="git@github.com:jrpinteno/dotfiles.git"
    dotfiles_directory="$HOME/dotfiles"

    if [ -d "$dotfiles_directory" ]; then
        echo "Dotfiles directory already exists. Aborting."
        exit 1
    fi

    git clone "$dotfiles_repository" "$dotfiles_directory"

    create_symlink "$dotfiles_directory/git/gitconfig" "$HOME/.gitconfig"
    create_symlink "$dotfiles_directory/nvim" "$HOME/.config/nvim"

    if [ "$is_mac" = true ]; then
        create_symlink "$dotfiles_directory/mac/Xcode/Templates" "$HOME/Library/Developer/Xcode/Templates"
        create_symlink "$dotfiles_directory/mac/Xcode/UserData" "$HOME/Library/Developer/Xcode/UserData"
    fi
}

install_tools() {
    # Install Oh-My-Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    else
        echo "Oh-My-Zsh already installed."
    fi

    # Install Homebrew if not installed
    if [ "$is_mac" = true ]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" --unattended < /dev/null
        else
            echo "Homebrew already installed."
        fi

        brew bundle --file "$HOME/dotfiles/mac/Brewfile"
    fi
}

main() {
    tools=false
    [[ "$(uname)" == "Darwin" ]] && is_mac=true || is_mac=false

    while getopts ":t" opt; do
        case ${opt} in
            t )
                tools=true
                ;;
            \? )
                echo "Invalid option: -$OPTARG" 1>&2
                exit 1
                ;;
        esac
    done

    install_dotfiles

    if [ "$tools" = true ]; then
        install_tools
    fi
}

main "$@"

