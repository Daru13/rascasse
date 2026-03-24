set -g pad " "

set user_fg_color "white"
set user_bg_color "blue"
set user_fg_color "white"
set root_bg_color "red"
set root_fg_color "white"

## Function to show a segment
function prompt_segment -d "Function to show a segment"
  # Get colors
  set -l bg $argv[1]
  set -l fg $argv[2]

  # Set 'em
  set_color -b $bg
  set_color $fg

  # Print text
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3]
  end
end

## Function to show current status
function show_status -d "Function to show the current status"
  if [ -n "$SSH_CLIENT" ]
    prompt_segment blue black " SSH "
    set pad ""
  end
end

function show_virtualenv -d "Show active python virtual environments"
  if set -q VIRTUAL_ENV
    set -l venvname (basename "$VIRTUAL_ENV")
    prompt_segment white black " ($venvname) "
  end
end

## Show user if not in default users
function show_user -d "Show user"
  if not contains $USER $default_user; or test -n "$SSH_CLIENT"
    set -l host (hostname -s)
    set -l who (whoami)

    set -l uid (id -u $USER)

    if [ $uid -eq 0 ]
      prompt_segment $root_bg_color $root_fg_color " $who "
    else
      prompt_segment $user_bg_color $user_fg_color " $who "
    end
  end
end

function _set_venv_project --on-variable VIRTUAL_ENV
    if test -e $VIRTUAL_ENV/.project
        set -g VIRTUAL_ENV_PROJECT (cat $VIRTUAL_ENV/.project)
    end
end

# Show directory
function show_pwd -d "Show the current directory"
  set fish_prompt_pwd_dair_length 0

  set -l pwd
  if [ (string match -r '^'"$VIRTUAL_ENV_PROJECT" $PWD) ]
    set pwd (string replace -r '^'"$VIRTUAL_ENV_PROJECT"'($|/)' '≫ $1' $PWD)
  else
    set -l long_pwd (prompt_long_pwd)
    if [ "$long_pwd" = "/" ]
      set pwd "/"
    else if string match --regex "^/" "$long_pwd" > /dev/null
      # If the path is absolute, remove the leading slash.
      set pwd (string sub -s 2 "$long_pwd" | sed "s#/#  #g")
    else
      set pwd (echo "$long_pwd" | sed "s#/#  #g")
    end
  end
  prompt_segment white black "$pad$pwd "
end

# Show prompt w/ privilege cue
function show_prompt -d "Shows prompt with cue for current priv"
  set -l uid (id -u $USER)

  if [ $uid -eq 0 ]
    prompt_segment $root_bg_color brwhite " "
  else
    prompt_segment $user_bg_color brwhite " "
  end

  set_color normal
end

## SHOW PROMPT
function fish_prompt
  set -l uid (id -u $USER)
  set -g RETVAL $status

  echo ""
  show_status
  show_virtualenv

  show_user
  if [ $uid -eq 0 ]
    prompt_segment $root_fg_color $root_bg_color ""
  else
    prompt_segment $user_fg_color $user_bg_color ""
  end

  show_pwd
  if [ $uid -eq 0 ]
    prompt_segment $root_bg_color $root_fg_color ""
  else
    prompt_segment $user_bg_color $user_fg_color ""
  end

  show_prompt
  if [ $uid -eq 0 ]
    prompt_segment normal $root_fg_color ""
  else
    prompt_segment normal $user_bg_color ""
  end

  prompt_segment normal normal " "
end
