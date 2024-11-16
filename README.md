# gitlatex

gitlatex is designed to bridge the gap in academic projects where contributors have different roles: some focus on coding and producing tables and figures, while others focus solely on writing. In these cases, integrated solutions like Python notebooks are often unsuitable because (1) writers may not use statistical software, and (2) writing often requires precise formatting that advanced tools like LaTeX can provide, which simple Markdown-to-LaTeX conversions cannot match. Consequently, such projects often resort to cloud storage solutions without version control, missing the advantages of tracking changes in both code and LaTeX.

gitlatex addresses this need by enabling the synchronization of LaTeX projects managed in a Git repository with directories outside the repository (e.g., a Dropbox folder). The package is built with the assumption that the Git repository maintains a central library of shared tables and figures (by default, `./assets`), with each LaTeX project stored in its own folder within the repository (e.g., `./tex/article` for the paper, and `./tex/presentation` for the slides). gitlatex provides R functions to streamline syncing the local copy of each project with their remote counterpart.

## Installation

Install the latest version of gitlatex package from GitHub with:

```
# install.packages("remotes")
remotes::install_github("rferrali/gitlatex")
```

## Usage

To get started, use `gitlatex::init()` to set up gitlatex in a new or existing project. By default, the package assumes that tables and figures are stored in the `./assets` directory. Two configuration files are used:

- **Public configuration file** (by default, `./gitlatex.json`): Specifies the path to the assets directory and the local paths of each LaTeX project within the repository.
- **Private configuration file** (by default, `./gitlatex.private.json`): Indicates the remote paths for each project. This file is unique to each contributor’s environment and should not be committed to the repository.

After initialization, use `gitlatex::push()` to push the latest version of each project to its corresponding remote directory, along with the assets folder. To synchronize the current state of each remote project directory back into the repository, use `gitlatex::pull()`.

gitlatex simplifies collaboration by allowing coders and writers to work seamlessly within their preferred tools while benefiting from the version control and change-tracking capabilities of Git. The `push()` and `pull()` functions are also designed for safe use within a CLI environment, making them ideal for integration with Makefiles or other automation scripts.

```
library(gitlatex)
gitlatex::init( # these are the defaults
    public = "./gitlatex.json",  
    private = "./gitlatex.private.json", 
    assets = "./assets"
)
# tweak the config files to add your own projects, following the built-in examples

# then, use the functions
config <- gitlatex::read_config(
    public = "./gitlatex.json",  
    private = "./gitlatex.private.json"
)
gitlatex::push(config)
gitlatex::pull(config)
```