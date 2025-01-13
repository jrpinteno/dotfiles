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
	local dotfiles_repository="https://github.com/jrpinteno/dotfiles.git"
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

	git remote set-url origin git@github.com:jrpinteno/dotfiles.git

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

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" -- --unattended || {
		print_message "$RED" "Failed to install Oh My Zsh."
		exit 1
	}

	create_symlink "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc" ".zshrc"

	print_message "$GREEN" "Oh My Zsh successfully installed."
}

install_homebrew() {
	if command -v brew &> /dev/null; then
		print_message "$GREEN" "Homebrew is already installed."∫
		return
	fi

	local homebrew_config_dir="$XDG_CONFIG_HOME/homebrew"
	mkdir -p "$homebrew_config_dir"
	echo "HOMEBREW_USER_ENVIRONMENT=$DOTFILES_ENV" >> "$homebrew_config_dir/brew.env"
	mkdir -p "$HOME/Library/LaunchAgents"

	print_message "$CYAN" "Installing Homebrew..."

	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" || {
		print_message "$RED" "Failed to install Homebrew."
		exit 1
	}

	print_message "$GREEN" "Homebrew installed successfully."
	print_message "$CYAN" "Setting Homebrew environment..."

	echo >> "$HOME/.zprofile"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
	eval "$(/opt/homebrew/bin/brew shellenv)"

	create_symlink "$HOME/dotfiles/mac/Brewfile" "$homebrew_config_dir/Brewfile" "Brewfile (macOS only)"

	if [[ "$DOTFILES_ENV" == *home* ]]; then
		create_symlink "$HOME/dotfiles/mac/Brewfile.home" "$homebrew_config_dir/Brewfile.home" "Home Brewfile (macOS only)"
	fi

	if [[ "$DOTFILES_ENV" == *dev* ]]; then
		create_symlink "$HOME/dotfiles/mac/Brewfile.dev" "$homebrew_config_dir/Brewfile.dev" "Dev Brewfile (macOS only)"
	fi

	brew update

	print_message "$GREEN" "Homebrew environment configured successfully."
}

brew_packages() {
	print_message "$CYAN" "Installing packages from Brewfile..."

	brew bundle --file "$XDG_CONFIG_HOME/homebrew/Brewfile" --verbose || {
		print_message "$RED" "Failed to install packages from Brewfile."
		exit 1
	}

	brew autoupdate start 86400
	print_message "$GREEN" "Homebrew packages installed successfully."
}

create_config_symlinks() {
	local dotfiles_directory="$HOME/dotfiles"

	print_message "$CYAN" "Linking dotfiles/configuration..."

	create_symlink "$dotfiles_directory/git/gitconfig" "$HOME/.gitconfig" ".gitconfig"
	create_symlink "$dotfiles_directory/nvim" "$XDG_CONFIG_HOME/nvim" "NeoVim"
}

main() {
	if [[ -z "$1" ]]; then
		print_message "$RED" "Usage: $0 [home|work] [--only-dotfiles]"
		exit 1
	fi

	print_message "$CYAN" "Starting setup..."

	local os_type
	os_type="$(uname -s)"

	local only_dotfiles=false
	local dev_environment=false

	while [[ "$#" -gt 0 ]]; do
		case "$1" in
			--only-dotfiles)
				only_dotfiles=true
				shift
				;;

			--dev)
				dev_environment=true
				shift
				;;

			home|work)
				export DOTFILES_ENV="$1"
				shift
				;;

			*)
				print_message "$RED" "Invalid argument: $1"
				print_message "$CYAN" "Usage: $0 [home|work] [--only-dotfiles | --dev]"
				exit 1
				;;
		esac
	done

	if [[ -z "$DOTFILES_ENV" ]]; then
		print_message "$RED" "Missing environment. Use 'home' or 'work'."
		exit 1
	fi

	if [ "$only_dotfiles" = true ] && [ "$dev_environment" = true ]; then
		print_message "$RED" "Can't combine --only-dotfiles with --dev"
		print_message "$CYAN" "Usage: $0 [home|work] [--only-dotfiles | --dev]"
	fi

	if [ "$dev_environment" = true ]; then
		DOTFILES_ENV="${DOTFILES_ENV} dev"
	fi

	# Install Xcode CLI tools, required to use git
	command -v "xcode-select -p" >/dev/null 2>&1; has_xcode=1 || { has_xcode=0; }
	if [ "$has_xcode" -eq 0 ]; then
		echo "Installing XCode CLI Tools..."
		sudo xcode-select --install
	else
		 xcode-select -p
	fi

	export XDG_CONFIG_HOME="$HOME/.config"

	clone_dotfiles
	install_oh_my_zsh

	local zshenv_file="$HOME/.zshenv"
	echo "export DOTFILES_ENV=$DOTFILES_ENV" >> "$zshenv_file"
	echo "export XDG_CONFIG_HOME=$HOME/.config" >> "$zshenv_file"
	export DOTFILES_ENV
	export XDG_CONFIG_HOME

	if [ "$os_type" = "Darwin" ] && [ "$only_dotfiles" = false ]; then
		install_homebrew
		brew_packages
	fi

	create_config_symlinks

	print_message "$GREEN" "Setup completed successfully!"
}

main "$@"
