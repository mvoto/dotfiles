" This configs were updated to use neovim and True Colors(if using Terminator,
" it requires latest versions to be installed)

" Leader
let mapleader = ","

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile Appraisals set filetype=ruby
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Highlight current line
set cursorline

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  let g:ackprg = 'ag --vimgrep'

  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0

  " CtrlP highlight color
  let g:ctrlp_buffer_func = { 'enter': 'BrightHighlightOn', 'exit':  'BrightHighlightOff', }

  function BrightHighlightOn()
    hi CursorLine guibg=#4d5056
  endfunction

  function BrightHighlightOff()
    hi CursorLine guibg=#191919
  endfunction

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

" Make it obvious where 80 characters is
set textwidth=100
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

" Switch between the last two files
nnoremap <leader><leader> <c-^>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" vim-test mappings
nnoremap <silent> <Leader>t :TestFile<CR>
nnoremap <silent> <Leader>s :TestNearest<CR>
nnoremap <silent> <Leader>l :TestLast<CR>
nnoremap <silent> <Leader>a :TestSuite<CR>
nnoremap <silent> <leader>gt :TestVisit<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<space>

" Treat <li> and <p> tags like the block tags they are
" let g:html_indent_tags = 'li\|p'

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Yank current relative file path
nnoremap <leader>yp :let @+ = expand("%")<CR>

" configure syntastic syntax checking to check on open as well as save
let g:syntastic_check_on_open=1
let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute \"ng-"]
let g:syntastic_eruby_ruby_quiet_messages =
    \ {"regex": "possibly useless use of a variable in void context"}

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
set diffopt+=vertical

set clipboard+=unnamedplus

if has('persistent_undo')
  set undodir=~/.vimundo      " undo dir
  set undofile                " persistent undo
  set undolevels=1000         " undo limit number
  set undoreload=10000        " undo lines to be reloaded
endif
" Persistent undo won't work without these 3 following options:
set nobackup
set noswapfile      " No need for backups and swap files
set hidden          " Hide non-saved buffers

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

" Remove whitespaces on save
fun! StripTrailingWhitespace()
  " don't strip on these filetypes
  if &ft =~ 'modula2\|markdown|mkd|md'
    return
  endif
  %s/\s\+$//e
endfun
autocmd BufWritePre * call StripTrailingWhitespace()

" Code climate linter config: https://github.com/wfleming/vim-codeclimate#variables
autocmd FileType javascript let b:codeclimateflags="--engine eslint"
autocmd FileType ruby let b:codeclimateflags="--engine rubocop"
autocmd FileType scss let b:codeclimateflags="--engine scss-lint"

" JSX syntax on js files
let g:jsx_ext_required = 0

" airline configs
let g:airline_powerline_fonts=1
" let g:airline_theme='material'
let g:airline_enable_branch=1
let g:airline_enable_syntastic=1
let g:airline_detect_paste=1

" theme's config to bold methods etc.
let g:enable_bold_font = 1

" Starts matchmaker(to highlight repeated words)
let g:matchmaker_enable_startup = 1

" NeoMake options
call neomake#configure#automake('rw')
let g:neomake_javascript_enabled_makers = ['eslint_d', 'flow']
let g:neomake_sass_enabled_makers = ['sasslint']
let g:neomake_scss_enabled_makers = ['sasslint']
let g:neomake_ruby_enabled_makers = ['rubocop']
let g:neomake_ruby_shell_makers = ['shellcheck']
let g:neomake_ruby_sh_makers = ['shellcheck']
let g:neomake_ruby_bash_makers = ['shellcheck']

" CodeClimate
autocmd FileType javascript let b:codeclimateflags="-e eslint -e fixme -e duplication"
autocmd FileType ruby let b:codeclimateflags="-e rubocop -e brakeman -e duplication -e fixme"
autocmd FileType scss let b:codeclimateflags="-e csslint -e fixme -e duplication"

" Git
" Auto-clean fugitive buffers
autocmd BufReadPost fugitive://* set bufhidden=delete
" Auto turn on spell checker in git commit message buffer
autocmd BufReadPost COMMIT_EDITMSG setlocal spell
autocmd BufReadPost PULLREQ_EDITMSG setlocal spell
autocmd BufReadPost PULLREQ_EDITMSG execute "-1read! git branch --points-at HEAD | sed 's/^\* *//g'"

" Asana + hub
autocmd BufReadPost PULLREQ_EDITMSG setlocal spell
autocmd BufReadPost PULLREQ_EDITMSG call InitPullRequest()

function! InitPullRequest()
  let branch_name = system("git branch --points-at HEAD | cut -f2- -d' '")
  let commits = split(system("git log master.. --pretty='format:%B'"), '\n\n')
  let think_task_id =  toupper(matchstr(branch_name, '\v(rmrf|cf|gs|uxf|tfg)-\d+'))

  let asana_task = system('asana tasks | grep -i ' . think_task_id)
  let asana_task_id = matchstr(asana_task, '\v\d+')
  let asana_task_title = matchstr(asana_task, '\v\[' . think_task_id . '\].*\ze\n')

  call system('asana browse ' . asana_task_id)
  execute 'normal! dG'
  silent put! =branch_name
  silent put =''
  silent put ='[' . asana_task_title . ']()'
  let asana_task_url_pos = getcurpos()
  let asana_task_url_pos[2] = strlen(getline(asana_task_url_pos[1])) " end of the line
  silent put =''
  silent put ='Changes'
  silent put ='======='
  silent put =''
  let before_commits_pos = getcurpos()
  silent put =commits
  call cursor(asana_task_url_pos[1], asana_task_url_pos[2], asana_task_url_pos[3])
  call input('Copy URL from Asana browser tab')
  execute 'normal! "+PGdk'

  execute 'g/^/m' . before_commits_pos[1]
  execute 'normal! G'
  silent execute before_commits_pos[1] + 1 . ',.s/^/- /'
endfunction

" NERDTree shortcuts and hidden files
nmap <leader>n :NERDTreeToggle<cr>
nmap <leader>f :NERDTreeFind<cr>
let NERDTreeShowHidden=1

" Autotags config(ctags for better navigation)
let g:autotagTagsFile="my-ctags"

" True Colors
set termguicolors
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Colorscheme
set background=dark
" colorscheme hybrid_material
colorscheme new-railscasts
