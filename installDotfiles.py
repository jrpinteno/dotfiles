import argparse
import os
import platform
import subprocess
import sys

def create_symlink(source, destination):
    try:
        os.symlink(source, destination)
    except FileExistsError:
        if os.path.islink(destination):
            consent = input(f"Override existing symlink {destination}? (y/N) ")

            if consent.lower() == 'y':
                os.remove(destination)
                os.symlink(source, destination)
        else:
            print(f"Error: {destination} already exists as a {'directory' if os.path.isdir(destination) else 'file'}")

def install_dotfiles(is_mac):
    dotfiles_repository = "git@github.com:jrpinteno/dotfiles.git"
    dotfiles_directory = os.path.expanduser("~/dotfiles")

    if os.path.exists(dotfiles_directory):
        print("Dotfiles directory already exists. Aborting.")
        exit(1)

    subprocess.run(["git", "clone", dotfiles_repository, dotfiles_directory])

    create_symlink(os.path.join(dotfiles_directory, "git/gitconfig"), os.path.join(os.path.expanduser("~/.gitconfig")))
    create_symlink(os.path.join(dotfiles_directory, "nvim"), os.path.join(os.path.expanduser("~/.config/nvim")))

    if is_mac:
        create_symlink(os.path.join(dotfiles_directory, "mac/Xcode/Templates"), os.path.join(os.path.expanduser("~/Library/Developer/Xcode/Templates")))
        create_symlink(os.path.join(dotfiles_directory, "mac/Xcode/UserData"), os.path.join(os.path.expanduser("~/Library/Developer/Xcode/UserData")))

def install_tools(is_mac):
    # Install Oh-My-Zsh
    if not os.path.exists(os.path.expanduser("~/.oh-my-zsh")):
        subprocess.run(["/bin/bash", "-c", "eval \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""])
    else:
        print("Oh-My-Zsh already installed.")

    # Install Homebrew if not installed
    if is_mac:
        if subprocess.call(["which", "brew"]):
            status = subprocess.run(["/bin/bash", "-c", "eval \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\""])

            if status.returncode:
                print(f"Could not install Homebrew. [errorCode: {status.returncode}, message: {status.stderr}]")
                sys.exit(1)
        else:
            print("Homebrew already installed.")

        subprocess.run(["brew", "bundle", "--file", os.path.expanduser("~/dotfiles/mac/Brewfile")])

def main():
    parser = argparse.ArgumentParser(description="Setup new device configurations.")
    parser.add_argument("-t", "--tools", help="Install Oh-My-Zsh", action="store_true")

    args = parser.parse_args()
    is_mac = plaftorm.system() == 'Darwin'

    install_dotfiles(is_mac)

    if args.tools:
        install_tools(is_mac)

if __name__ == "__main__":
    main()
