" vim script to animate the Bowling KATA in javascript inside the vim editor
"
"  this script require snipMate. snipMate provide the Mocha code Snippet.
"
" Maintainer: Etienne Rossignon
" Contributor: Etienne Rossignon
" LastModifed:
"
" to run from the vim command line:
"
"
"
"
source /projects/TDDExample2/pythonscripts/RunMocha.vim
let &makeprg="mocha -R tap"

" Error: bar
"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let &errorformat  = '%AError: %m' . ','
let &errorformat .= '%Z%*[\ ]%m (%f:%l:%c)' . ','

"     at Object.foo [as _onTimeout] (/Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2:9)
let &errorformat .= '%*[\ ]%m (%f:%l:%c)' . ','

" /Users/Felix/.vim/bundle/vim-nodejs-errorformat/test.js:2
"   throw new Error('bar');
"         ^
let &errorformat .= '%A%f:%l,%Z%p%m' . ','

" Ignore everything else
"ER let &errorformat .= '%-G%.%#'

function! HookCoreFilesIntoQuickfixWindow()
   let files = getqflist()
   for i in files
      let filename = bufname(i.bufnr)

      " Non-existing file in the quickfix list, assume a core file
      if !filereadable(filename)
        " Open a new split / buffer for loading this core file
        execute 'split ' filename
        " Make this buffer modifiable
        set modifiable
        " Set the buffer options
        setlocal buftype=nofile bufhidden=hide
        " Clear all previous buffer contents
        execute ':1,%d'
        " Load the node.js core file (thanks @izs for pointing this out!)
        execute 'read !node -e "process.binding(\"natives\").' expand('%:r') '"'
        " Delete the first line, always empty for some reason
        execute ':1d'
        " Tell vim to treat this buffer as a JS file
        set filetype=javascript
        " No point in making this file writable
        setlocal nomodifiable
        " Point our quickfix entry to this (our current) buffer
        let i.bufnr = bufnr("%")
        " Close the split, so our little hack stays in the background
        close
      endif
   endfor
   " call setqflist(files)
endfunction

au QuickfixCmdPost make call HookCoreFilesIntoQuickfixWindow()



let rnd = localtime() % 0x10000
function! Random()
  let g:rnd = (g:rnd * 31421 + 6927) % 0x10000
  return g:rnd
endfun

function! Choose(n) " 0 n within
  return (Random() * a:n) / 0x10000
endfun 

function! Rnd(m)
    return Choose(a:m)
endfunction

function! Wait(mil)
    redraw
    let timetowait = float2nr(a:mil) . " m"
    "xx echo timetowait
    exe 'sleep '.timetowait
    return ""
endfunction 

function! W()
    return Wait(Rnd(6)+5)
endfunction



"
"
"
function! SlowType(text)
   let chars = split(a:text, '.\zs')
   let a = ''
   for c in chars
       let a .= "\<C-R>=W()\<C-M>" . c
   endfor
   return a
endfunction

function! FakeTyping(text)
   let chars = split(a:text, '.\zs')
   for c in chars
      execute "normal zza" . c . "\<esc>"
      call W()
      redraw
   endfor
endfunction

let bowlingKataPause = -1
function! Pause(msg)
  redraw!
  if (g:bowlingKataPause == -1)  
    let a = input(a:msg . "  ( press enter to continue )"," ")
  else 
    echo a:msg
    sleep 1000 m
  endif
  return ""
endfunction

" set auto ident on
" set ai!
" set tab size
" set ts=4
set makeprg=mocha\ -R\ tap

let source_file="c:\\temp\\Bowling.js"
let test_file="c:\\temp\\test\\Bowling_test.js"

let s:triggerSnippet =  "\<C-R>=TriggerSnippet()\<CR>"


function! bowlingKata#AddNewTest_it(description)
  execute "normal A\n" . SlowType("  it") . s:triggerSnippet . "\<C-X>'\<esc>"
  execute "normal x\<left>"
  call FakeTyping(a:description)
  sleep 100 m
  " move down one line, where we can type the body of the test
  execute "normal j"  
  call FakeTyping("\n")
  execute "normal 0C\<esc>"
endfunction

function! bowlingKata#Step0()
  " delete all buffers
  silent! bufdo bdelete! 
  silent! execute "!del " . g:source_file 
  silent! execute "!del " . g:test_file  
  silent! execute "!del " . "c:\\tmp\\mocha.mytap"  
  only!

  call Pause("###### Starting Bowling KATA step 1")
 
  " run Mocha Once, this will create the testing window at the bottom
  call RunMocha()
  
  " now move the cursor to the top window and split it
  execute "normal \<C-W>\<Up>" 
  "split windows
  vsplit
  call Pause(" first test should succeed but with 0 test")
  
  "xx execute "normal \<C-W>=" 

  " create source file on the left 
  enew!
  set expandtab
  set shiftwidth=2
  set softtabstop=2
  match none
  setlocal comments-=://
  setlocal comments+=f://
  setlocal formatoptions-=croql
  setlocal noautoindent
  setlocal nocindent
  setlocal nosmartindent
  setlocal indentexpr=


  execute "write! " . g:source_file

  " create test file on the right
  execute "normal \<C-W>\<Right>"  
  enew!
  set expandtab
  set shiftwidth=2
  set softtabstop=2
  match none
  setlocal comments-=://
  setlocal comments+=f://
  setlocal formatoptions-=croql
  setlocal noautoindent
  setlocal nocindent
  setlocal nosmartindent
  setlocal indentexpr=


  execute "write! " . g:test_file 

  call FakeTyping("var fs = require(\"fs\");\n")
  sleep 100 m
  call FakeTyping("var Bowling = require(\"../Bowling\");\n")
  call FakeTyping("var should = require(\"should\");\n")
  sleep 100 m

  " add the first desc("...",function(){}) using the snipmate snippet
  execute "normal i" . SlowType("desc") . s:triggerSnippet . "\<C-X>\<esc>"
  call FakeTyping("Bowling Game") 

  sleep 100 m
  " move down one line 
  execute "normal j"  
  sleep 100 m

  " add the first test
  call bowlingKata#AddNewTest_it("should score zero when constructed")

  call FakeTyping("\<tab>\<tab>var game = new Bowling.Game();\n")
  call FakeTyping("\<tab>\<tab>game.score.should.equal(0);\n")
  redraw
  write! 

  execute "normal \<C-W>\<Left>"  
  call FakeTyping("var Game = function () {\n")
  call FakeTyping("\n}")
  call FakeTyping("\nexports.Game = Game;")

  call RunMocha()
  call Pause("Test has failed : method score is not defined")
endfunction

function! bowlingKata#SwitchToSource()
  execute "normal \<C-W>\<C-T>\<C-W>\<left>"    
  execute "buffer " . g:source_file
  setlocal formatoptions-=croql
endfunction

function! bowlingKata#SwitchToTest()
  "  set cursor in test buffer
  execute "normal \<C-W>\<C-T>\<C-W>\<right>"
  execute "buffer " . g:test_file
  setlocal formatoptions-=croql
endfunction

" move the cursor after the n'th test
" a.k.a after the n'th it("...",function(){...}) block
function! bowlingKata#SeekEndTest(n)
  " goto top of the file
  execute "0"
  " 
  execute "normal " . a:n . "/^\\s*it(/e\<CR>%"
  call CenterScreenOnCursor()

endfunction

" correct first error : score is not defined 
function! bowlingKata#Step1()

  call bowlingKata#SwitchToSource()

  execute "normal 1/exports\<cr>i\n\<up>\n"
  call Pause(" ready ?")
  call FakeTyping("Game.prototype.score = function () { \n")
  call FakeTyping("   return 0; \n")
  call FakeTyping("}\n")

  " run tests again
  "
  call RunMocha()

  call bowlingKata#SwitchToTest()

  "  fix the score bug by adding () 
  execute "normal /\\.score/e\<cr>a()\<esc>"
  write!

  "  run test again
  call RunMocha()

  call Pause(" Tests are now OK. It's time to refactor")
endfunction


function! bowlingKata#Step2()

  call bowlingKata#SwitchToTest()
  set nu

  " move  at the end of the first it(...,{ }) block
  call bowlingKata#SeekEndTest(1)
  
  call bowlingKata#AddNewTest_it("should score 20 when all rolls hit one pin") 

  call FakeTyping("\t\tvar game = new Bowling.Game();\n")
  call FakeTyping("\t\tfor (var i=0; i < 20 ; i++) {\n\n\t\t}\n")
  execute "normal \<up>\<up>"
  call FakeTyping("\t\t\tgame.roll(1);")
  execute "normal \<down>\<down>"
  call FakeTyping("\t\tgame.score().should.equal(20);")

  call RunMocha()
  call Pause(" Test failed  : roll method is missing => let's add it")

  call bowlingKata#SwitchToSource()

  " find insertion point for new prototypes
  execute "normal 1/exports\<cr>i\n\<up>\n"

  call Pause(" ready ?")
  call FakeTyping("Game.prototype.roll = function (pin) { \n")
  call FakeTyping("\treturn 0; \n")
  call FakeTyping("}\n\n")
  
  call RunMocha()
  call Pause(" Test failed  : score is wrong => let's fix it")

  " search score method
  call bowlingKata#SwitchToSource()
  execute "normal /Game = function\<CR>\<down>0C"            . SlowType("    this._score = 0;")     . "\<esc>"
  execute "normal /prototype.score = function\<CR>\<down>0C" . SlowType("    return this._score;")  . "\<esc>"
  execute "normal /prototype.roll = function\<CR>\<down>0C"  . SlowType("    this._score += pin;")  . "\<esc>"
 
  call RunMocha()
  call Pause(" Test succeeded  : => let's refactor")

endfunction

" refactoring : pull out construction in beforeEach 
function! bowlingKata#Step3()
  call bowlingKata#SwitchToTest()

  " highlight in red what we are refactoring
  match Error /game = new Bowling.Game();/

  " lets copy the var game ... line
  execute "/var game = new"
  " store in register 0
  execute "normal \"0yy"   

  execute "normal /describe\<CR>\<down>0i\n" . SlowType("  ") .  SlowType("var game;\n\tbeforeEach( function() {\n\t});\n")  . "\n\<up>\<up>\<up>\<esc>"

  " remember line where we want to move the code
  let l=line(".")

  redraw 

  echo "refactor out new Bowling.Game() " . l
  sleep 1000 m
  
  execute "g/new Bowling.Game/d"

  " paste line in clipboard
  execute l
  put 0
  " remove  var 
  s/var //

  "   execute "normal 0C" . SlowType("    game = new Bowling.Game();") . "\<esc>"
  
  call RunMocha()
  call Pause(" Test is still OK"  )
  " reset hightlighted text
  call bowlingKata#SwitchToTest()
  match none 
  echo " end of Step 3"
endfunction

function! bowlingKata#Step4()

  call bowlingKata#SwitchToTest()

  " move to the end of the 2nd it(...) block
  call bowlingKata#SeekEndTest(2)

  call bowlingKata#AddNewTest_it("should score 25 after a SPARE followed by a 6 and a 3")

  call FakeTyping("\t\tgame.roll(4);\n")
  call FakeTyping("\t\tgame.roll(6); // spare\n")
  call FakeTyping("\t\tgame.roll(6);\n")
  call FakeTyping("\t\tgame.roll(3);\n")
  call FakeTyping("\t\t// score is (10 + 6 ) + 6 + 3 = 25\n")
  call FakeTyping("\t\tfor (var i=0; i < 16 ; i++) {\n\n\t\t}\n")
  execute "normal \<up>\<up>"
  call FakeTyping("\t\t\tgame.roll(0);")
  execute "normal \<down>\<down>"
  call FakeTyping("\t\tgame.score().should.equal(25);")
 
  call RunMocha()
  call Pause(" Test failed  : => let's fix it")
  echo "" 
endfunction

function! CenterScreenOnCursor()
  execute "normal zz"
endfunction

" fix code with spare
function! bowlingKata#Step5() 

  call bowlingKata#SwitchToSource()

  execute "normal /this._score = 0\<CR>0C"            . SlowType("\tthis.round = 0;\n")     . "\<esc>"
  call FakeTyping("\tthis._roll = new Array(21);\n")
  call FakeTyping("\tfor ( var i = 0 ; i < 21 ; i ++ ) {\n\t\tthis._roll[i] = 0 ;\n\t}\n")

  execute "normal /return this._score\<CR>0C"            . SlowType("\n") . "\<esc>"
  call FakeTyping("\tvar _score = 0;\n")
  call FakeTyping("\tfor (var f = 0; f < 10 ; f ++ ) {\n")
  call FakeTyping("\t\t_score += this._roll[ f * 2 ] + this._roll[ f * 2 + 1 ];\n") 
  call FakeTyping("\t}\n")
  call FakeTyping("\treturn _score;\n")
  write!

  call Pause(" we change our mind, change is big, lets temporarly ignore newly created test")
  call bowlingKata#SwitchToTest()
  call bowlingKata#disableTest("should score 25")

  call RunMocha()
  call Pause(" Test failed !  OOPS !")
  call Pause(" we forget to refactor roll!  : => let's finish refactoring")

  call bowlingKata#SwitchToSource()
  " search the line we want to replace
  execute "normal /this._score += pin\<CR>"
  call CenterScreenOnCursor()
  " replace the line by an empty line
  execute "normal 0C". SlowType("\n") . "\<esc>"
  " add new code
  call FakeTyping("\tthis._roll[ this.round ] = pin;\n")
  call FakeTyping("\tthis.round += 1;\n")

  call RunMocha()
  call Pause(" Test succeeded  : => refactoring has worked !")
  call Pause(" We can re-enable the test") 
  call bowlingKata#SwitchToTest()
  call bowlingKata#enableTest("should score 25")
  
  call RunMocha()
  call Pause(" Test is failing, lets fix it")
  
  call bowlingKata#SwitchToSource()
  execute("normal /f < 10\<CR>A\n")
  call CenterScreenOnCursor()
  call FakeTyping("\t\tif (this._roll[ f * 2 ] + this._roll[ f * 2 + 1] == 10 ) {\n")
  call FakeTyping("\t\t\t_score += this._roll[ ( f + 1 ) * 2 ];\n")
  call FakeTyping("\t\t}\n")
  redraw
  
  call RunMocha()
  call Pause(" Test is now OK , let's refactor")
  echo "" 

endfunction

" refactor by extracting isSpare( f ) 
function! bowlingKata#Step6()

  call bowlingKata#SwitchToSource()
  " move to first line
  execute "0" 
  " search start of if stattemtn 
  execute "normal /if (/e\<CR>"
  call CenterScreenOnCursor()
  sleep 500 m
  " mark statement selection in visual mode
  execute "normal v%" 
  " pause so that we can see
  call Pause("let's factor out this code by creating  a isSpare method")

  " yank code that calculate if frame is spare is
  execute "normal y"

  " replace with new code
  execute "normal gvc" . SlowType("( this.isSpare(f) )") . "\<esc>"
  call Pause("")
  " now move above methode definition
  " search backward for prototype
  execute "normal ?prototype\<CR>0i\n\<up>"
  call FakeTyping("Game.prototype.isSpare = function ( f ) {\n\n}\n")
  " paste code that we yanked
  execute "normal \<up>\<up>i" . SlowType("\<tab>return ") . "\<esc>pA" .SlowType(";") . "\<esc>"
  redraw 

  call RunMocha()
  call Pause(" Test is now OK , refactoring was successful")
  echo "" 
endfunction

" adding a test case with a strike
function! bowlingKata#Step7()

  call bowlingKata#SwitchToTest()
  call Pause("let's create a test to verify score with a single STRIKE")
  
  call bowlingKata#SeekEndTest(3)

  call bowlingKata#AddNewTest_it("should score 28 after a STRIKE followed by a 6 and a 3")

  call FakeTyping("\t\tgame.roll(10); // Strike\n")
  call FakeTyping("\t\tgame.roll(6);\n")
  call FakeTyping("\t\tgame.roll(3);\n")

  call FakeTyping("\t\t// score is (10 + 6 + 3 ) + 6 + 3 = 28\n")

  call FakeTyping("\t\tfor (var i=0; i < 16 ; i++) {\n\n\t\t}\n")
  execute "normal \<up>\<up>"
  call FakeTyping("\t\t\tgame.roll(0);")
  execute "normal \<down>\<down>"
  call FakeTyping("\t\tgame.score().should.equal(28);")
 
  call RunMocha()
  call Pause(" Test failed  : => let's fix it")
  echo "" 

endfunction

" fix score calculation
function! bowlingKata#Step8()
  call bowlingKata#SwitchToSource()

  execute "normal /this.isSpare\<CR>0"
  call FakeTyping("\t\tif ( this.isStrike(f) ) {\n\n\t\t} else")
  execute "normal \<up>"
  call FakeTyping("\t\t\t_score += this._roll[ ( f + 1 ) * 2 ] + this._roll[ ( f + 1 ) * 2  + 1];")
  write!

  echo " add the isStrike method"
  execute "normal ?prototype.isSpare\<CR>\<up>"
  call FakeTyping("Game.prototype.isStrike = function ( f ) {\n")
  call FakeTyping("\treturn (this._roll[ f * 2 ] == 10 ) ;\n")
  call FakeTyping("}\n")
   
  call RunMocha()
  call Pause(" Score is still wrong : => let's fix it")
  echo ""
endfunction


" fix roll when strike is run
function! bowlingKata#Step9()
  
  call bowlingKata#SwitchToSource()
  execute "normal /prototype.roll\<CR>zz"
  execute "normal /this.round += 1;/e\<CR>"
  execute "normal A\n\<esc>"
  call FakeTyping("\tif ( pin == 10 ) {\n")
  call FakeTyping("\t\tthis.round += 1;\n\t}\n")

  call RunMocha()
  call Pause("  All tests pass  : => let's refactor")
  echo "" 

endfunction

" refactor out the frameScore function
function! bowlingKata#Step10()
  call bowlingKata#SwitchToSource()
  call Pause(" let's create a function to calculate the score of a single frame")  
  execute "0"
  execute "normal /prototype.score\<CR>\<up>0" 
  execute "normal zz"
  
  call FakeTyping("\nGame.prototype.frameScore = function ( f ) {\n\t// Calculate Frame score\n\n")
  call FakeTyping("}\n") 
  
  " let extract function body from score 
  execute "normal /if ( this.isStrike\<CR>?{\<CR>"
  " enter visual mode an select to the matching }
  execute "normal v%\<up>$o\<down>0<gvygv"
  call Pause("we want to move this code into a dedicated method")

  " delete selected text
  execute "normal gvC\<esc>"

  call FakeTyping("\t\t_score += this.frameScore( f );\n") 
  
  execute "normal /Calculate Frame score/e\<CR>"
  call FakeTyping("\n\tvar _score = 0;\n")
  call FakeTyping("\treturn _score;") 
  " put text before
  put!

  call RunMocha()
  call Pause("  All tests pass  : => let's keep refactoring")
  echo "" 

endfunction

" add roll many in test
function! bowlingKata#Step11()
  
  call bowlingKata#SwitchToTest()
  execute "0"
  match Error /for(.*){.*}/
  execute "normal /for (var i=\<CR>"
  execute "normal V\<down>\<down>\"0ygv"
  call Pause("let create a rollMany function for this code (DRY)")
  execute "normal gvc\<esc>"
  call FakeTyping("\t\tgame.rollMany(20,1);")
  execute "normal ?describe\<CR>A\n\<esc>"
  call FakeTyping("\n\tBowling.Game.prototype.rollMany = function(rolls,pins) {\n")
  call FakeTyping("\t\tfor (var r = 0 ; r < rolls ; r++ ) {\n")
  call FakeTyping("\t\t\tthis.roll(pins);\n")
  call FakeTyping("\t\t}\n")
  call FakeTyping("\t}") 
  
  call RunMocha()
  call Pause("  All tests pass  : => let's use rollMany elsewhere")
  echo "" 
  
  " search for () block
  execute "normal /for (var i=\<CR>"
  " select this line + the next 2 lines and cut it 
  execute "normal V\<down>\<down>c\<esc>"
  " write new code
  call FakeTyping("\t\tgame.rollMany(16,0);")

  execute "normal /for (var i=\<CR>"
  execute "normal V\<down>\<down>c\<esc>"
  call FakeTyping("\t\tgame.rollMany(16,0);")

  call RunMocha()
  call Pause("  All tests pass  : => let's keep refactoring")
  echo "" 

endfunction

" replace the code
" the pattern can contain %% which will be replaced with sub
" for instance 
"     to replace  this.roll[ f * 1]  with func(f)
"     and         this.roll[ ( f + 1) * 1] with func((f+1))
"  -  [ ] and *   are escaped
"  -  single space are replaced with optional white space: \\s*  
"
function! bowlingKata#Refactor(oldCode, newCode, variation) 

   call Pause(" replacing  " . a:oldCode . " with " . a:newCode . " where %% = " . a:variation)

   let v = a:oldCode 
   let v = substitute(v,"[","\\\\[","g")
   let v = substitute(v,"]","\\\\]","g")
   let v = substitute(v,"*","\\\\*","g")
   let v = substitute(v," ","\\\\s*","g")
   let v = substitute(v,"%%",a:variation,"g")
   let v = "\\m" . v 
  
   "xx call Pause(" pattern = " . v)

   let n = substitute(a:newCode,"%%",a:variation,"g")

   " remove redundant parenthesis 
   let n = substitute(n,"((","(","g")
   let n = substitute(n,"))",")","g")
   
   " hightlight search
   set hlsearch 
   execute "normal /" . v . "\<CR>zz"
   redraw
   sleep 800 m
   execute "s/" . v . "/" . n . "/g"
   redraw
   sleep 800 m
   set nohlsearch 
endfunction

" refactor out framePinDown()
function! bowlingKata#Step12()
  call bowlingKata#SwitchToSource()
  call Pause ("let's make the score calculation clearer (DRY) ! ")

  call bowlingKata#Refactor("this._roll[ %% * 2 ] + this._roll[ %% * 2 + 1 ]","this.frameDownPin(%%)","f")
  call bowlingKata#Refactor("this._roll[ %% * 2 ] + this._roll[ %% * 2 + 1 ]","this.frameDownPin(%%)","f")
  call bowlingKata#Refactor("this._roll[ %% * 2 ] + this._roll[ %% * 2 + 1 ]","this.frameDownPin(%%)","( f + 1 )")

  call Pause("this calculates the number of knocked down pin in a frame")

  "  add new method  
  execute "normal ?prototype.isStrike\<CR>\<up>"
  call FakeTyping("\n/**\n")
  call FakeTyping(" * returns the number of pins that have been knocked down in frame *f* \n")
  call FakeTyping(" */\n")
  call FakeTyping("Game.prototype.frameDownPin = function ( f ) { \n")
  call FakeTyping("   return this._roll[ f * 2 ] + this._roll[ f * 2 + 1 ];\n")
  call FakeTyping("}\n")

  call RunMocha()
  call Pause("  All tests pass  : => let's keep refactoring")
  echo "" 

endfunction


" golden score test
function! bowlingKata#Step13()

  call bowlingKata#SwitchToTest()
  call Pause ("let's add the golden score test : 12 strikes in a row ( 9 strikes + 3 strikes in last frame!) ")
  
  call bowlingKata#SeekEndTest(4)
  call bowlingKata#AddNewTest_it("should score 300  after 12 STRIKES (golden score)")
  call FakeTyping("\t\tgame.rollMany(12,10);\n")
  call FakeTyping("\t\tgame.score().should.equal(300);")
  
  call RunMocha()
  call Pause(" Test failed  : => let's fix it")

  echo "" 
  call Pause(" In fact, we may be too anbitious, lets try a small test first")
  
  call bowlingKata#disableTest("should score 300")
  call RunMocha()

  call Pause(" Test failed  : => let's fix it")

  call bowlingKata#SeekEndTest(4)
  call bowlingKata#AddNewTest_it("should score 52  for X,X,6,2,0,...,0")
  call FakeTyping("\t\tgame.roll(10);\n")
  call FakeTyping("\t\tgame.roll(10);\n")
  call FakeTyping("\t\tgame.roll(6);\n")
  call FakeTyping("\t\tgame.roll(2);\n")
  call FakeTyping("\t\tgame.rollMany(14,0);\n")
  "//  score 10 + 10 + 6 = 26
  "// score 10 +  6 + 2 =  18 
  "//  score       6 + 2 =  8
  call FakeTyping("\t\tgame.score().should.equal(52);\n")

  call RunMocha()
  call Pause(" Test failed  : => let's fix it")

endfunction

" fix double strike issue
function! bowlingKata#Step14()

  call bowlingKata#SwitchToSource()
  execute "0"
  execute "normal /if ( this.isStrike(f)\<CR>A\n\<esc>"
  call FakeTyping("\t\t\tif ( this.isStrike(f + 1) ) {\n")
  call FakeTyping("\t\t\t\t_score += 10 + this._roll[ ( f + 2 ) * 2 ] ;\n")
  call FakeTyping("\t\t\t} else {")
  execute "normal \<down>>>\<esc>A\n\t\t\t}\n\<esc>"
  
  call RunMocha()
  call Pause(" Test is now OK : => let's move on")
   
endfunction

function! bowlingKata#enableTest(start_of_should_line)
  match Error /xit(/
  execute "0,$s/xit(\'\s*" . a:start_of_should_line . "/it(\'" . a:start_of_should_line . "/g"
  execute "normal zz"
endfunction

function! bowlingKata#disableTest(start_of_should_line)
  match Error /xit(.*$/
  execute "0,$s/it(\'\s*" . a:start_of_should_line . "/xit(\'" . a:start_of_should_line . "/g"
  execute "normal zz"
  call Pause(" note that test has been excluded by adding a x to it")
endfunction

" uncomment and fix golden score test
function! bowlingKata#Step15()
  " reenable test

  call bowlingKata#SwitchToTest()
  call bowlingKata#enableTest("should score 300")
  redraw
  call RunMocha()
  call Pause("Test is still failing, let fix it")
  call bowlingKata#SwitchToSource()
  set hlsearch
  execute "normal /if ( pin == 10/e\<CR>zz"
  call FakeTyping(" && this.round<=18 ") 
  set nosearch
  call RunMocha()

  execute "0"
  set hlsearch
  execute "normal /var _score = 0;/e\<CR>"
  call FakeTyping("\n\tif ( f == 9 ) { // last frame is special \n")
  call FakeTyping("\t\t_score += this._roll[ f * 2 + 2 ];\n")
  call FakeTyping("\t} else ");
  execute "normal J"
  redraw
  set nohlsearch
  call RunMocha()

endfunction

" refactor further by extracting a frame bonus method
function! bowlingKata#Step16()

endfunction

function! bowlingKata#All()

   let g:bowlingKataPause = 0
   call bowlingKata#Step0()
   call bowlingKata#Step1()
   call bowlingKata#Step2()
   call bowlingKata#Step3()
   call bowlingKata#Step4()
   call bowlingKata#Step5()
   call bowlingKata#Step6()
   call bowlingKata#Step7()
   call bowlingKata#Step8()
   call bowlingKata#Step9()
   call bowlingKata#Step10()
   call bowlingKata#Step11()
   call bowlingKata#Step12()
   call bowlingKata#Step13()
   call bowlingKata#Step14()
   call bowlingKata#Step15()

endfunction

