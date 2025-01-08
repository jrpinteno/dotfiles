#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_message() {
	local color="$1"
	local message="$2"

	echo -e "${color}${message}${NC}"
}

create_symlink() {
	local source="$1"
	local destination="$2"
	local label="$3"

	if [ ! -e "$source" ]; then
		print_message "$RED" "Source $label not found: $source"
		return
	fi

	if [ -e "$destination" ]; then
		print_message "$RED" "Error: $destination already exists as a $(file "$destination" | awk '{print $2}')"
		return
	fi

	if [ -L "$destination" ]; then
		read -rp "Override existing symlink $destination? (y/N) " consent

		if [ "$consent" == "y" ] || [ "$consent" == "Y" ]; then
			ln -sf "$source" "$destination"
		fi
	else
		ln -s "$source" "$destination"
	fi

	print_message "$GREEN" "Symlink created for $label."
}

clone_dotfiles() {
	local dotfiles_repository="git@github.com:jrpinteno/dotfiles.git"
	local dotfiles_directory="$HOME/dotfiles"

	if [ -d "$dotfiles_directory" ]; then
		print_message "$RED" "Dotfiles directory already exists. Aborting."
		exit 1
	fi

	print_message "$CYAN" "Cloning dotfiles repository..."
	git clone "$dotfiles_repository" "$dotfiles_directory" || {
		print_message "$RED" "Failed to clone dotfiles repository."
		exit 1
	}

	create_symlink "$dotfiles_directory/git/.gitconfig" "$HOME/.gitconfig" ".gitconfig"

	# if [ "$is_mac" = true ]; then
	# 	create_symlink "$dotfiles_directory/mac/Xcode/Templates" "$HOME/Library/Developer/Xcode/Templates"
	# 	create_symlink "$dotfiles_directory/mac/Xcode/UserData" "$HOME/Library/Developer/Xcode/UserData"
	# fi
}

install_oh_my_zsh() {
	if [ -d "$HOME/.oh-my-zsh" ]; then
		print_message "$GREEN" "Oh My Zsh is already installed."
		return
	fi

	print_message "$CYAN" "Installing Oh My Zsh..."

	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended || {
		print_message "$RED" "Failed to install Oh My Zsh."
		exit 1
	}

	create_symlink "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"
	print_message "$GREEN" "Oh My Zsh successfully installed."
}

install_homebrew() {
	if command -v brew &> /dev/null; then
		print_message "$GREEN" "Homebrew is already installed."
		return
	fi

	print_message "$CYAN" "Installing Homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" --unattended < /dev/null || {
		print_message "$RED" "Failed to install Homebrew."
		exit 1
	}

	create_symlink "$HOME/dotfiles/mac/Brewfile" "$HOME/Brewfile" "Brewfile (macOS only)"

	print_message "$GREEN" "Homebrew installed successfully."
}

brew_packages() {
	print_message "$CYAN" "Installing packages from Brewfile..."

	brew bundle --file "$HOME/dotfiles/mac/Brewfile" || {
		print_message "$RED" "Failed to install packages from Brewfile."
		exit 1
	}
}

create_config_symlinks() {
	create_symlink "$HOME/dotfiles/nvim" "$HOME/.config/nvim" "NeoVim"
}

main() {
	print_message "$CYAN" "Starting setup..."

	local os_type
	os_type="$(uname -s)"

	install_oh_my_zsh
	clone_dotfiles

	if [ "$os_type" = "Darwin" ]; then
		install_homebrew
		brew_packages
	fi

	create_config_symlinks

	print_message "$GREEN" "Setup completed successfully!"
}

main "$@"
