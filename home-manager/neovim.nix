# neovim.nix
#
# Home-manager module converted from the uploaded _vimrc.
#
# Import this from your home.nix, e.g.:
#   imports = [ ./neovim.nix ];
#
# WHAT WAS DROPPED / CHANGED (read before using):
#
# 1. The "athame" / g:user_mode split-brain logic is gone. The original file
#    behaved differently depending on whether it was launched by a tool
#    called "athame" (user_mode=0) or normally (user_mode=1) -- including a
#    whole set of athame-only keymaps (OA/OB/OC/OD, <leader>u, <leader>ww).
#    This config keeps only the "normal" (user_mode=1) branch, since that's
#    the generally-useful editor config. Say the word if you actually want
#    the athame bits ported too.
#
# 2. The "EPIGEN_ADD_BLOCK_*/EPIGEN_DEL_BLOCK_*" markers were a templating
#    system for generating machine-specific vimrcs. I kept whichever branch
#    was already marked ACTIVE / uncommented in your file (VIKTOR_BIGBOX +
#    VIKTOR_THINKPAD, colorscheme "default"/papercolor) and discarded the
#    alternate commented-out branches (jellybeans/raggi/grun colorschemes,
#    vim-airline, YouCompleteMe, syntastic, vim-glsl, papis-vim, etc.) since
#    they were already disabled in your source file.
#
# 3. `source ~/.vim/pluginconfig/*.vim` lines can't be converted because
#    those files weren't included in the upload. Merge their contents into
#    the `extraConfig` string below (see the placeholder near the bottom).
#
# 4. Some plugins in your Plug list are obscure enough that they may not
#    exist in nixpkgs' vimPlugins set. They're built manually from GitHub
#    below with placeholder hashes (`lib.fakeSha256`) -- you MUST replace
#    these or the build will fail. Easiest way:
#       nix run nixpkgs#nix-prefetch-github -- <owner> <repo>
#    then paste the resulting sha256 in.
#
# 5. deoplete + nvim-yarp + vim-hug-neovim-rpc is a legacy, Python-based
#    completion stack. It's ported as-is for fidelity, but if you're setting
#    up nvim fresh you'd almost certainly rather use nvim-cmp + nvim-lspconfig.
#    Happy to write that version instead if you'd like.

{ pkgs, lib, ... }:

let
  vimPluginFromGitHub =
    { owner, repo, rev ? "master", sha256 ? lib.fakeSha256 }:
    pkgs.vimUtils.buildVimPlugin {
      pname = repo;
      version = rev;
      src = pkgs.fetchFromGitHub { inherit owner repo rev sha256; };
    };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      # colorscheme (kept even though "colorscheme default" is active below;
      # remove if you don't actually use jellybeans)
      jellybeans-vim

      # git
      vim-fugitive
      vim-gitgutter
      vim-conflicted

      # syntax / highlighting
      vim-rainbow
      vim-cpp-enhanced-highlight

      # statusline (this replaced vim-airline in your source file)
      lightline-vim

      # misc utilities
      vim-suda
      goyo-vim
      vim-arduino
      vimux
      nerdtree
      vim-startify
      vim-signature
      vim-abolish
      vim-argwrap
      vim-python-pep8-indent
      quick-scope
      tagbar

      # completion stack (legacy deoplete -- see note 5 above)
      deoplete-nvim
      nvim-yarp
      vim-hug-neovim-rpc

      vimtex
      vimwiki
      vim-tmux-navigator
      supertab
      vim-unimpaired
      ctrlp-vim
      vim-tmux-runner
      vim-clang-format
      vim-easy-align
      asyncrun-vim
      vim-commentary

      vim-repeat
      vim-multiple-cursors
      ultisnips
      targets-vim
      vim-surround
      vim-exchange
    ] ++ (with pkgs.vimPlugins; [
      # ReplaceWithRegister / AnsiEsc / DoxygenToolkit are vim-scripts.org
      # mirrors; nixpkgs attr names for these can be finicky. Verify with
      # `nix search nixpkgs vimPlugins` first -- these are best guesses.
      ReplaceWithRegister
      AnsiEsc
    ]) ++ [
      # Not (reliably) packaged in nixpkgs -- built from GitHub directly.
      # >>> Replace every lib.fakeSha256 below before building. <<<
      (vimPluginFromGitHub { owner = "kiddos";          repo = "deoplete-cpp"; })
      (vimPluginFromGitHub { owner = "deoplete-plugins"; repo = "deoplete-tag"; })
      (vimPluginFromGitHub { owner = "klaxalk";          repo = "vim-ros"; })
      (vimPluginFromGitHub { owner = "ron89";            repo = "thesaurus_query.vim"; })
      (vimPluginFromGitHub { owner = "vim-scripts";      repo = "MatlabFilesEdition"; })
      (vimPluginFromGitHub { owner = "vim-scripts";      repo = "DoxygenToolkit.vim"; })
      (vimPluginFromGitHub { owner = "mklabs";           repo = "split-term.vim"; })
      (vimPluginFromGitHub { owner = "ardagnir";         repo = "united-front"; })
    ];

    extraConfig = ''
      " ---------------------------------------------------------------
      " General settings
      " ---------------------------------------------------------------
      set lazyredraw
      set clipboard=unnamedplus
      syntax enable

      set splitbelow
      set splitright
      set number
      set relativenumber
      set scrolloff=10
      set showmatch
      set title

      " Indentation
      set expandtab
      set shiftwidth=2
      set softtabstop=2
      set tabstop=2
      set autoindent
      set smartindent

      " Search
      set ignorecase
      set smartcase
      set hlsearch
      set incsearch
      set synmaxcol=400

      " Wildmenu
      set wildmenu
      set wildmode=full
      set wildignore+=*/Downloads/**,*/Desktop/**,*/build/**

      " Path for filename completion / gf / find
      set path+=~/git/**
      set path+=~/.config/nvim/UltiSnips/**

      " Line wrap
      set wrap
      set linebreak
      set nolist
      set wrapmargin=0
      set textwidth=0

      set completeopt=longest,menuone

      set nocursorline
      set nocursorcolumn

      colorscheme default
      let g:tex_flavor = 'latex'
      let g:deoplete#enable_at_startup = 1

      " ---------------------------------------------------------------
      " Leader keys
      " ---------------------------------------------------------------
      nnoremap , <NOP>
      let mapleader = ","
      nmap <space> ,
      let maplocalleader = "`"

      " ---------------------------------------------------------------
      " Save with sudo (suda.vim)
      " ---------------------------------------------------------------
      cmap w!! w suda://%

      " ---------------------------------------------------------------
      " Functions
      " ---------------------------------------------------------------
      function! NumberToggle()
        if(&relativenumber == 1)
          set nornu
        else
          set relativenumber
        endif
      endfunc
      nnoremap <leader>r :call NumberToggle()<cr>

      function! TogglePaste()
        if(&paste == 0)
          set paste
        else
          set nopaste
        endif
      endfunc
      nnoremap <leader>p :call TogglePaste()<cr>

      function! EnableCursorLines()
        set cursorline
        set cursorcolumn
      endfunc
      au FileType python call EnableCursorLines()

      function! ToggleCursorLines()
        if(&cursorline == 0)
          set cursorline
          set cursorcolumn
        else
          set nocursorline
          set nocursorcolumn
        endif
      endfunc
      nnoremap <leader>c :call ToggleCursorLines()<cr>

      " Highlight all instances of word under cursor when idle. z/ toggles.
      function! AutoHighlightToggle()
        let @/ = '''
        if exists('#auto_highlight')
          au! auto_highlight
          augroup! auto_highlight
          setl updatetime=4000
          echo 'Highlight current word: off'
          return 0
        else
          augroup auto_highlight
            au!
            au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
          augroup end
          setl updatetime=500
          echo 'Highlight current word: ON'
          return 1
        endif
      endfunction
      nnoremap <leader>a :call AutoHighlightToggle()<cr>

      " ---------------------------------------------------------------
      " Keymaps
      " ---------------------------------------------------------------
      imap <expr> jk (pumvisible()?(empty(v:completed_item)?("<Esc>l"):("\<C-n>\<C-p>")):("\<Esc>l"))
      imap <leader>( ()<Esc>i
      imap <leader>{ {}<Esc>i

      nmap H ^
      vmap H ^
      nmap L $
      vmap L $

      nmap * *N
      vnoremap // y/<C-R>"<CR>

      map <Leader>fr :%s///g<left><left>
      map <Leader>frl :s///g<left><left>
      map <Leader>fa :%s//&/g<left><left>
      map <Leader>fal :s//&/g<left><left>

      map <Leader>m :wa\|make\|redraw!\|cc<CR>

      nnoremap gf <C-W>gf
      map <Leader>lv :lv //g ./**/*<c-f>^f/a

      " Ctrl+hjkl split navigation. NOTE: vim-tmux-navigator (also included)
      " normally provides its own <C-h/j/k/l> mappings for pane+split
      " navigation; these explicit ones may override/duplicate that.
      nnoremap <C-J> <C-W><C-J>
      nnoremap <C-K> <C-W><C-K>
      nnoremap <C-L> <C-W><C-L>
      nnoremap <C-H> <C-W><C-H>
      nnoremap <S-K> :tabp<cr>

      vnoremap . :normal @a<CR>

      " format whole document and return to original position
      nmap <leader>g :normal mggg=G'g<cr>:delmarks g<cr>zt:%s/\s\+$//g<cr>

      " delete into black hole register
      nmap <leader>d "_d

      " wrap word under cursor with an underscore, per <leader>o{i,o,p}
      nnoremap <leader>oi :delmark a<bar>:norm ma*:%s//_&/g<bar>:norm `a:delmark a<cr>
      nnoremap <leader>oo :delmark a<bar>:norm ma*:%s//_&_/g<bar>:norm `a:delmark a<cr>
      nnoremap <leader>op :delmark a<bar>:norm ma*:%s//&_/g<bar>:norm `a:delmark a<cr>

      command! WQ wq
      command! Wq wq
      command! W w
      command! Q q

      cnoreabbrev vt VTerm
      cnoreabbrev st Term

      " ---------------------------------------------------------------
      " Filetype-specific folding / filetype detection
      " ---------------------------------------------------------------
      au FileType m,matlab set foldmethod=marker foldmarker=%\ %{,%\ %}
      au FileType xdefaults set foldmethod=marker foldmarker=!\ {,!\ }
      au FileType bib,yml,yaml,sh,conf,python set foldmethod=marker foldmarker=#\ #{,#\ #}
      au FileType cpp set foldmethod=marker foldmarker=//{,//}
      au FileType roslaunch.xml set foldmethod=marker foldmarker=//{,//}
      au FileType xml,world,xacro set foldmethod=marker foldmarker={-->,<!--}

      au BufNewFile,BufRead *.sk setf sketch
      au FileType sk,sketch set foldmethod=marker foldmarker=%\ %{,%\ %}

      au BufNewFile,BufRead *.cl setlocal ft=c
      au BufNewFile,BufRead *.shadron set filetype=cpp
      au BufNewFile,BufRead *.tpp set filetype=cpp

      au BufNewFile,BufRead *.pln set list
      au BufNewFile,BufRead *.pln set listchars=tab:▸▸

      au BufNewFile,BufRead *.m map <Leader>. :VtrSendLinesToRunner<cr>
      au FileType md,vimwiki,markdown nnoremap <leader>m :AsyncRun ~/.scripts/md2html.sh %:p<cr>

      autocmd BufWritePost *.sk AsyncRun bash -c '%:p:h/compile_sketch.sh %:t'

      " ---------------------------------------------------------------
      " vim-startify bookmarks
      " (paths pointing at ~/.vim / ~/.vimrc updated to their nvim/home-manager
      " equivalents; adjust to taste)
      " ---------------------------------------------------------------
      let g:startify_bookmarks = [
            \ { 'b': '~/.bashrc' },
            \ { 'i': '~/.i3/config' },
            \ { 'p': '~/.config/papis/config' },
            \ { 'r': '~/.config/ranger/rc.conf' },
            \ { 't': '~/.tmux.conf' },
            \ { 'v': '~/.config/nvim/init.vim' },
            \ { 'x': '~/.Xresources' },
            \ { 'z': '~/.zshrc' },
            \ ]

      " ---------------------------------------------------------------
      " Per-plugin settings that used to live in
      " ~/.vim/pluginconfig/*.vim (nerdtree, argwrap, quick-scope, tagbar,
      " GoldenView, vim-ros, vimtex, vimwiki, ctrlp, vim-tmux-runner,
      " vim-clang-format, vim-easy-align, vim-conflicted,
      " vim-cpp-enhanced-highlight, vim-multiple-cursors, ultisnips,
      " vim-commentary).
      "
      " Those files weren't part of the upload, so paste their contents
      " here so home-manager can manage them declaratively:
      " ---------------------------------------------------------------

      " (paste pluginconfig contents here)

      " ---------------------------------------------------------------
      " Optional personal overrides, equivalent to the original
      " `source ~/.my.vimrc` escape hatch
      " ---------------------------------------------------------------
      if !empty(glob("~/.my.nvimrc"))
        source ~/.my.nvimrc
      endif
    '';
  };
}
