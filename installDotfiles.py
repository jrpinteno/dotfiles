import argparse
import os
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
        else
            print(f"Error: {destination} already exists as a {`directory' if os.path.isdir(destination) else 'file'}")
            sys.exit(1)


def install_dotfiles():
    dotfiles_repository = "https://github.com/jrpinteno/dotfiles.git"
    dotfiles_directory = os.path.expanduser("~/dotfiles")

    if os.path.exists(dotfiles_dir):
        print("Dotfiles directory already exists. Aborting.")
        exit(1)

    subprocess.run(["git", "clone", dotfiles_repository, dotfiles_directory])

    create_symlink(os.path.join(dotfiles_dir, "git/gitconfig"), os.path.join(os.path.expanduser("~/.gitconfig"))
    create_symlink(os.path.join(dotfiles_dir, "nvim"), os.path.join(os.path.expanduser("~/.config/nvim")))


def install_tools():
    home_application_directory = "~/Applications"

    # Install Oh-My-Zsh
    if not os.path.exists(os.path.expanduser("~/.oh-my-zsh")):
        subprocess.run(["sh", "-c", "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"])
    else:
        print("Oh-My-Zsh already installed.")

    # Install Homebrew if not installed
    if not subprocess.call(["which", "brew"]):
        status = subprocess.run(["/usr/bin/ruby", "-e", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"])

        if status.returncode:
            print(f"Could not install Homebrew. [errorCode: {status.returncode}, message: {status.stderr}]"))
            sys.exit(1)
    else:
        print("Homebrew already installed.")

    install_from_brew("nvim", "NeoVim")
    install_from_brew("diff-so-fancy")

    try
        import other_tools
    except ImportError:
        print("Could not find other_tools.py")


def install_from_brew(tool, name="", directory=""):
    if subprocess.run("which", tool):
        print("f{name if name else tool} was already installed")
        return

    subprocess.run("brew", "install", tool)


def main():
    parser = argparse.ArgumentParser(description="Setup new device configurations.")
    parser.add_argument("-t", "--tools", help="Install Homebrew, Neovim, Xcodes and Oh-My-Zsh", action="store_true")

    args = parser.parser_args()

    if args.tools:
        install_tools()

    install_dotfiles()


if __name__ == "__main__":
    main()
