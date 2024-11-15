# gitlatex

gitlatex is motivated by the fact that in many academic projects, some contributors (the coders) write statistical code that produce a series of tables and figures, while others (the writers) only do the writing, using those tables and figures. In such projects, integrated solutions such as Python notebooks are not appropriate, as (1) the writers won't use the statistical softwares, and (2) writing usually requires fine-tuning the layout, requiring the use of advanced solutions such as LaTeX, instead of Markdown turned into LaTeX. These projects typically end up putting everything into a shared folder hosted on cloud storage, and give up on version control. Yet, the project could benefit tremendously from using a version control solution such as Git, to track changes to both the code and the LaTeX. 

gitlatex solves this problem. It allows to sync LaTeX projects tracked on a Git repository with folders outside the repository (e.g., on a Dropbox folder). It operates under the assumptions that the Git repository generates a centralized library of tables and figures that are shared among all LaTeX projects. It is an `R` package that provides a series of commands to automate syncing. 

## Installation

Install the latest version of gitlatex package from GitHub with

```
# install.packages("remotes")
remotes::install_github("rferrali/gitlatex")
```

## Usage

Use `gitlatex::init()` to initialize gitlatex in a new or existing project. 

## How does this work? 