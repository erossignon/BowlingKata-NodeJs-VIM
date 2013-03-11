" run mocha and display results in the bottom window
" Maintainer: Etienne Rossignon
"


let mocharesult="\\tmp\\mocha.mytap"
let mochawin = -1

function! RunMocha()
   " save current windows number
   let g:old_win = winnr()
   " auto save document in active window
   silent write!
   
   if (g:mochawin == -1) 
     silent! execute "bd! " . g:mocharesult 
     " create the test result at the bottom
     silent! execute "botright new"
     " slightly reduce the test output window
     execute "normal 6\<C-W>-"
     silent! execute "write! " . g:mocharesult 
     redraw
     let g:mochawin = winnr()
     "xx echo " mocha windows is " . g:mochawin
     "xx sleep 3
   endif
   
   " activate test result window 
   execute "normal \<C-W>b"
   " purge test result window
   setlocal modifiable
   execute "1,$d"
   
   "xx silent! execute "bd! " . g:mocharesult 
   "xx execute "botright new"
   "xx silent! execute "write! " . g:mocharesult 
   
   " execute command and store result in current buffer 
   cd /temp
   read !mocha -R tap   
   " clean up the result by removing cluttering lines
   silent! 1,$g/Roaming/d  
   silent! 1,$g/node\.js/d 
   silent! 1,$g/module\.js/d  
   execute "0"
   " make sure first failing test is visibile
   if ( search("not ok") > 0 )
      silent! execute "/not ok/"
   else 
      silent! execute "/# tests/"
   endif
   silent! execute "normal zz"

   " apply syntax highlighting
   set filetype=mytap
   setlocal nomodifiable
   write!
   "xxx cgetbuffer   " read eror list from current buffer
   "xxx " build the quickfix list
   redraw
   "xxx cl " list all erro
   "xxx copen   
   "   " display error list
   "reactivate old window
   execute "normal \<C-W>t"
   execute g:old_win . "wincmd w"
endfunction

