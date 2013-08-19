vim script to simulate a TDD Bownling KATA with nodejs and mocha

##### prerequisites:
Before running the Bolwing Kata script in vim, you will need to make sure that some components are installed. 

###### installing vim
      
    ``` sudo yum install vim ```
    or
    ``` sudo apt-get install vim```

###### installing vundle & the required vim extensions

   - refers to https://github.com/gmarik/vundle
   - install vundle with the following command:
   ```git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle```
   - add the following in your ```~/.vimrc``` file 

```
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'snipMate'
Bundle 'mmozuras/snipmate-mocha'
filetype on
```

###### installing nodejs
   - refer to https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager
   
###### installing mocha & should
   ``` 
   sudo npm install mocha -g
   sudo npm install should -g
   ```


   
##### Launching run

 1. start vim
 2. type the following commands:
 
    ```
    :source <path>/bowlingKata.vim
    :call bownlingKata#All()
    ```



