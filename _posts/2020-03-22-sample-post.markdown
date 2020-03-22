---
layout: post
title: "Annoying beep on PyCharm + Oh My Zsh"
date: 2020-03-20 12:10
comments: true
categories: General
---

A few days ago I managed to solve an annoying issue with the PyCharm terminal. 
At the start and end of *every* command, there was this bell/beep/notification sound.
I didn't usually care about it much, but when I started working remotely and spending more time using headphones for code reviews and pair programming, this became a pain.

Changing the "Audible bell" setting on Pycharm did nothing. Google wasn't helpful here either, which led me to think the problem wasn't all that common.

I started to suspect zsh/oh-my-zsh, so I opened up a bash terminal, and - surprise! - the beep was gone, so it had to be zsh related.

I disabled the sourcing of `$ZSH/oh-my-zsh.sh` in my `.zshrc` file, and - surprise again! - no beeping. 

So the culprit was Oh My Zsh. Or, more specifically, Oh My Zsh within the PyCharm terminal. A plain Oh My Zsh console did not beep either.

So the following thing I did was google for the "bell" character and fiddled around a bit. I opened up a bash terminal and typed:

{% codeblock (bash.sh) %}
echo $'\a'
{% endcodeblock%}

This was the sound that was driving me nuts!

Next, I grepped the bell character inside my `~/.oh-my-zsh` folder:

{% codeblock zsh.sh %}
$> grep -R '\\a' ~/.oh-my-zsh/
/home/vagrant/.oh-my-zsh/lib/termsupport.zsh:      print -Pn "\e]2;$2:q\a" # set window name
/home/vagrant/.oh-my-zsh/lib/termsupport.zsh:      print -Pn "\e]1;$1:q\a" # set tab name
/home/vagrant/.oh-my-zsh/lib/termsupport.zsh:        print -Pn "\e]2;$2:q\a" # set window name
/home/vagrant/.oh-my-zsh/lib/termsupport.zsh:        print -Pn "\e]1;$1:q\a" # set tab name
/home/vagrant/.oh-my-zsh/lib/termsupport.zsh:    printf '\e]7;%s\a' "file://$HOST$URL_PATH"
{% endcodeblock %}

There were other results for plugins and themes I wasn't using, so I went and inspect the code inside the `termsupport.zsh` file:

{% codeblock termsupport.zsh (file.sh) %}
# Set terminal window and tab/icon title                                                                                                         #
# usage: title short_tab_title [long_window_title]
#

...

if [[ "$DISABLE_AUTO_TITLE" == true ]]; then
  return
fi

...

{% endcodeblock %}

Ok, so this is for setting window and tab titles on terminals, which isn't that helpful in PyCharm, and there is an environment variable to disable this plugin. But if I just export this variable on my `.zshrc` I will not have the plugin enabled outside PyCharm.

So the solution I came up with was:

{% codeblock ~/.zshrc (file.sh) %}
if [[ -n "$INSIDE_PYCHARM"  ]]; then
  export DISABLE_AUTO_TITLE=true  
fi
{% endcodeblock %}

Then on my PyCharm terminal settings for the project:

![image](/assets/images/pycharm-term.png)

*Viola!*

This felt so good I just needed to share. I hope someone finds this useful sometime.


