import os
import subprocess

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

dotfiles_repository = "https://github.com/jrpinteno/dotfiles.git"
dotfiles_directory = os.path.expanduser("~/dotfiles")

if os.path.exists(dotfiles_dir):
    print("Dotfiles directory already exists. Aborting.")
    exit(1)

subprocess.run(["git", "clone", dotfiles_repository, dotfiles_directory])

create_symlink(os.path.join(dotfiles_dir, "git/gitconfig"), os.path.join(os.path.expanduser("~/.gitconfig"))
create_symlink(os.path.join(dotfiles_dir, "nvim"), os.path.join(os.path.expanduser("~/.config/nvim")))
