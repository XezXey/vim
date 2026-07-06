" Rule: tmux send -t 2 ls Enter
" Rule: tmux send -t 2 '!!' Enter Enter
"
autocmd InsertLeave * call CopyWordUnderCursor()

" augroup OpenAllFoldsOnFileOpen
    " autocmd!
    " autocmd BufWinEnter * normal zR
    " echom "yes"
" augroup END

function! s:AfterDap(timer) abort
  execute 'DapViewOpen'
  execute 'DapContinue'
endfunction

function! s:OnCompileExit(command, output, line, job_id, exit_code, event) abort
  call setqflist([], 'r')
  
  execute "cexpr join(a:output, \"\n\")"
  let l:qf = getqflist()
  let l:errors = filter(copy(l:qf), 'v:val.valid')

  let b:building = v:false
  let b:build_ok = (a:exit_code == 0)
  lua require('spinner').stop()
  redrawstatus

  if a:exit_code == 0 && empty(l:errors)
    if a:line == 1
      echohl DiagnosticOk
      echom '✔ Build succeeded'
      echohl None
      " notify build succeeded
      lua vim.notify('Build succeeded', vim.log.levels.INFO, {title="Build Status"})
      cclose
    " elseif a:line == 2
    "   execute 'lua vim.notify("Running: ' . a:command . '", vim.log.levels.INFO, {title="Running"})'
    "   cclose
    endif
  else
    lua vim.notify('Build failed', vim.log.levels.ERROR, {title="Build Status"})
    botright cwindow 8
  endif

  if a:command =~ 'dpython'
    call timer_start(500, function('s:AfterDap'))
  endif
endfunction

function! FirstLineCompile(...) 
  let l:line = a:0 > 0 ? a:1 : 1
  let l:text = getline(l:line)

  if l:text !~ ':'
    return
  endif

  let l:s = split(l:text, ':', 1)

  if l:s[0] !~ 'Rule'
    return
  endif

  let b:building = 1
  let b:build_ok = v:null
  redrawstatus
  lua require('spinner').start()

  let l:command = trim(l:s[1])

  " clear quickfix
  call setqflist([], 'r')

  let l:output = []

  execute 'lua vim.notify("' . l:command . '", vim.log.levels.WARN, {title="Running Command"})'

  let l:job = jobstart(l:command, {
        \ 'stdout_buffered': v:true,
        \ 'stderr_buffered': v:true,
        \ 'on_stdout': {j,d,e -> extend(l:output, d)},
        \ 'on_stderr': {j,d,e -> extend(l:output, d)},
        \ 'on_exit': function('s:OnCompileExit', [l:command, l:output, l:line]),
        \ })

  if l:job <= 0
    echoerr 'Failed to start job'
  endif

  " let l:out = system(l:command)
  " try
    " cexpr l:out 
  " catch
    "echo l:out
  " endtry

  " if l:command =~ 'dpython'
    " call timer_start(500, {-> [execute('DapViewOpen'), execute('DapContinue')]})
  " endif
  " botright cwindow 8
  " echo l:out

endfunction 

function! RgCwd(query)
  let g:rgmode_query = a:query
  let g:rgmode_rgopt = "-g '!tags' --column --line-number --no-heading --color=always --smart-case"

  lua require'fzf-lua'.grep({rg_opts=vim.g.rgmode_rgopt, cwd=vim.fn.getcwd(), search=vim.g.rgmode_query, fzf_cli_args = '--nth 3.. -d :'}) 
endfunction

" ----------- Utility functions --------------

function! JumpThroughParameter(direction)
  let flag = a:direction == 1 ? '' : 'b'
  let s1 = searchpos('\S(\S', 'en' . flag, line('.'))
  let s2 = searchpos(', \S', 'en' . flag, line('.'))
  if s1 != [0, 0] && (s2 == [0, 0] || 
        \ ((flag == '' && s1[1] < s2[1]) || (flag == 'b' && s1[1] > s2[1])) )
    call search('\S(\S', 'e' . flag, line('.'))
  else
    call search(', \S', 'e' . flag, line('.'))
  endif
endfunction

function! CopyWordUnderCursor()
  let @w = expand('<cword>')
endfunction


