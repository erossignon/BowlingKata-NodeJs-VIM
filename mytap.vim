syntax match Error /^not ok .*$/ 
syntax match Question /^ok .*$/
syntax match Special /^ok .*# SKIP -$/
syntax match Question /^# fail 0$/
syntax match Error /^# tests 0$/

highlight myTapOK ctermfg=Green ctermbg=Black

