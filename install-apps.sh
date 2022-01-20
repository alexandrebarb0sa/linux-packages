#!/bin/bash

local=$(pwd)

# REPOSITORIES
sudo add-apt-repository universe
sudo apt-get update

declare -A url prefix flatpak

url["miniconda3"]="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh"
prefix["miniconda3"]="/usr/local/miniconda3"

url["sublime"]="https://download.sublimetext.com/sublimehq-pub.gpg"
url["vscode"]="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
url["hypnotix"]="https://github.com/linuxmint/hypnotix/releases/download/1.1/hypnotix_1.1_all.deb"

flatpak["repo"]="https://flathub.org/repo/flathub.flatpakrepo"
flatpak["runtime"]="runtime/org.freedesktop.Platform/x86_64/21.08"

main() {

  sudo apt update
  for dir in $(ls -d *); do
    cd $dir 2> /dev/null;
    for pkg in $(ls *.packs 2> /dev/null ); do
      printf "\n[${dir^^}] << $pkg >>\n"
      printf "├─┬\n"
      while IFS= read -r line || [ -n "$line" ]; do
        if [ ! -z $line ]; then
          if [[ "$line" == *"#"* ]]; then
            continue

          elif [[ "$line" == *"[url]"* ]]; then
            install_urls "$line"

          elif [[ "$line" == *"[flatpak]"* ]]; then
            install_flatpaks $( echo $line | sed -e "s/^\[flatpak\]//" ) 

          elif [[ "$line" == *"[npm]"* ]]; then
            npm_pack=$(echo $line | cut -d ']' -f 2)
            if [ -z "$(sudo npm list -g | grep $npm_pack)" ]; then 
              printf "| ├── $line: Instalando pacote... \n"
              sudo npm install -g $npm_pack
            else
              printf "| ├── $line: Pacote já instalado! \n"
            fi

          else
            if [ -z "$(dpkg -s $line 2>&1 > /dev/null)" ]; then
              printf "| ├── $line: Pacote já instalado! \n"
            else
              printf "| ├── $line: Instalando pacote... \n"
              sudo apt-get install -y $line > /dev/null
              sudo apt-get -f install > /dev/null
            fi
          fi
        fi
      done < $pkg
    done
    cd "$local"
  done
  echo
}

install_urls(){
  if [ $1 == "[url]miniconda3" ];then 
    if [ -z $(which conda) ]; then
      printf "| ├── conda: Instalando pacote...\n"
      curl -O ${url["miniconda3"]}
      bash Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p ${prefix["miniconda3"]}
      rm Miniconda3-py39_4.9.2-Linux-x86_64.sh
      if [ -d "../conda-envs" ]; then
        for env in $(ls ../conda-envs/*.yaml);do
          conda env create -f $env
        done
      fi
    else
      printf "| ├── conda: Pacote já instalado!\n"
    fi
  fi

  if [ $1 == "[url]sublime" ]; then
    if [ -z $(which subl) ];then
      printf "| ├── sublime: Instalando pacote...\n"
      wget -qO - ${url["sublime"]} | sudo apt-key add -
      echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
      sudo apt-get update
      sudo apt-get install sublime-text
    else
      printf "| ├── sublime: Pacote já instalado!\n"
    fi
  fi

  if [ $1 == "[url]vscode" ]; then
    if [ -z $(which code) ];then
      printf "| ├── vscode: Instalando pacote...\n"
      wget ${url["vscode"]} 
      for deb in $(ls *.deb 2> /dev/null ); do
        if [[ "$deb" == *"code"* ]]; then
          sudo dpkg -r "$deb"
          sudo apt-get -f install > /dev/null
          rm "$deb"
        fi
      done
    else
      printf "| ├── vscode: Pacote já instalado!\n"
    fi
  fi 

  if [ $1 == "[url]hypnotix" ]; then
    if [ -z $(which hypnotix) ];then
      printf "| ├── hypnotix: Instalando pacote...\n"
      wget ${url["hypnotix"]} -O hypnotix.deb
      for deb in $(ls *.deb 2> /dev/null ); do
        if [[ "$deb" == *"hypnotix"* ]]; then
          sudo dpkg -i "$deb" -y
          rm "$deb"
        fi
      done
    else
      printf "| ├── hypnotix: Pacote já instalado!\n"
    fi
  fi 

}

install_flatpaks(){

  case $1 in 

    "flatpak")
      if [ -z $(which $1) ];then
        printf "| ├── $1: Instalando pacote...\n"
        apt install $1
        apt install gnome-software-plugin-flatpak
        flatpak --user remote-add --if-not-exists flathub ${flatpak["repo"]}
        flatpak --user install flathub ${flatpak["runtime"]}
      else
        printf "| ├── $1: Pacote já instalado!\n"
      fi
      return
      ;;

    "Minder")
      pkg="com.github.phase1geo.minder"
      ;;

    "FontFinder")
      pkg="io.github.mmstick.FontFinder"
      ;;

    "Natron")
      pkg="fr.natron.Natron"
      ;;   

    "TradeSim")
      pkg="com.github.horaciodrs.tradesim"
      ;;

    "Markets")
      pkg="com.bitstower.Markets"
      ;;  

    "Scribl")
      pkg="ink.scribl.Scribl"
      ;;        

    "QPrompt")
      pkg="com.cuperino.qprompt"
      ;;  

    "Identity")
      pkg="org.gnome.gitlab.YaLTeR.Identity"
      ;;     

    *)
      ;;
  esac

  if [ -z "$(flatpak list | grep $1)" ]; then 
    printf "| ├── $1: Instalando pacote...\n"
    flatpak install --user flathub "$pkg" -y > /dev/null
  else
    printf "| ├── $1: Pacote já instalado!\n"
  fi

  export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share":$XDG_DATA_DIRS

}

main; exit


# ├─┬

# ├──
# │ │ └──