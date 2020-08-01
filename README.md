# vim-easy-replace
![License](https://img.shields.io/github/license/kqito/vim-easy-replace)

vim plugin for quick and easy replacement

## Demo
<p align="center">
  <img src="https://user-images.githubusercontent.com/29191111/89102455-5361bb80-d444-11ea-9d0a-6332e532b48c.gif" width="800" alt="demo">
</p>


## Features
- Intuitive replacements.
- Highlight to be replaced.
- Easily replace the word under the cursor.
- Leave the replacement history in the command line history.
- The function to replace only the selected area in visual mode.


## Installation
### Manual (with vim's built-in packages function)
First, create a directory to put this plugin. (check your `packpath`.)

```
$ mkdir -p ~/.vim/pack/kqito/start/
$ cd ~/.vim/pack/kqito/start/
```

Next, download this plugin.

```
$ git clone https://github.com/kqito/vim-easy-replace
```

Now you can use `easy-replace`.

### With plugin manager
You can install it as follows.

- **[Vundle](https://github.com/VundleVim/Vundle.vim)**
  - `Plugin 'kqito/vim-easy-replace'`

- **[Dein](https://github.com/Shougo/dein.vim)**
  - `call dein#add('kqito/vim-easy-replace')`

- **[Vim-plug](https://github.com/junegunn/vim-plug)**
  - `Plug 'kqito/vim-easy-replace'`


## Customize options
You can customize some options.

|variable name|default value|description|
|:-----------|:---------:|:----------|
|g:easy_replace_enable|1|Enable `easy-replace`. (If set 0, `easy-replace` will not work.)|
|g:easy_replace_launch_key|\<Leader\>ra|Key to launch `easy_replace`|
|g:easy_replace_launch_in_visual_key|\<Leader\>ra|Key to launch in visual mode `easy_replace`|
|g:easy_replace_launch_cword_key|\<Leader\>rc|Key to replace the word under the cursor with "easy_replace".|
|g:easy_replace_launch_cword_in_visual_key|\<Leader\>rc|Key to replace the word under the cursor in visual mode with "easy_replace".|
|g:easy_replace_highlight_ctermbg|'green'|Color for highlighting the replacement target.|
|g:easy_replace_highlight_guibg|'green'|Color for highlighting the replacement target.|
|g:easy_replace_add_history|1|Leave the replace command in the command line history after the replacement.|


## License
[MIT © kqito](./LICENSE)
