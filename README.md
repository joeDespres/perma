# permr
inspired by [gitlinker](https://github.com/ruifm/gitlinker.nvim)
An Rstudio Addin to create github [perma links](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-a-permanent-link-to-a-code-snippet)

```
devtools::install_github("joeDespres/permr")
```

:white_check_mark: Create github perma link at cursor: `perma_link_to_console` <br /> 
:white_check_mark: Open github at cursor or selection: `perma_open_perma_link` <br /> 
:white_check_mark: Move cursor to perma link: `perma_move_to_link` <br />

Recommended key bindings
```
~/.config/rstudio/keybindings/addins.json
{
    "perma::perma_link_to_console": "Ctrl+`",
    "perma::perma_move_to_link": "Ctrl+T",
    "perma::perma_open_perma_link": "Ctrl+G"
}
```
