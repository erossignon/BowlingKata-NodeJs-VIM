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
     silent execute "bd! " . g:mocharesult 
     execute "botright new"
     execute "write! " . g:mocharesult 
     redraw
     let g:mochawin = winnr()
     "xx echo " mocha windows is " . g:mochawin
     "xx sleep 3
   endif
   
   execute "normal \<C-W>b"
   silent execute "bd! " . g:mocharesult 
   execute "botright new"
   execute "write! " . g:mocharesult 
    
   cd /temp
   read !mocha -R tap   
   1,$g/Roaming/d               " delete line containing /Roaming
   1,$g/node\.js/d               " delete line containing /Roaming
   1,$g/module\.js/d               " delete line containing /Roaming
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

