#!/bin/bash

local=$(pwd)

# REPOSITORIES
sudo add-apt-repository universe
sudo apt-get update

# URLs and PREFIX PATH
declare -A url
declare -A prefix

url["miniconda3"]="https://repo.anaconda.com/miniconda/Miniconda3-py39_4.9.2-Linux-x86_64.sh"
prefix["miniconda3"]="/usr/local/miniconda3"

url["sublinme"]="https://download.sublimetext.com/sublimehq-pub.gpg"
url["vscode"]="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

main() {
  for dir in $(ls -d *); do
    cd $dir 2> /dev/null;
    for packs in $(ls *.packs 2> /dev/null ); do
      printf "\n[${dir^^}] << $packs >>\n"
      while IFS= read -r line || [ -n "$line" ]; do
        if [ ! -z $line ]; then
          if [[ "$line" == *"*"* ]]; then
            download_url "$line"          
          else
            if [ -z "$(dpkg -s $line 2>&1 > /dev/null)" ]; then
              printf "$line: Pacote já instalado! \n"
            else
              printf "$line: Instalando pacote \n"
              sudo apt-get install -y $line > /dev/null
              sudo apt-get -f install > /dev/null
            fi
          fi
        fi
      done < $packs
    done
    cd "$local"
  done
  echo
}

download_url (){
  if [ $1 == "*miniconda3" ];then 
    if [ -z $(which conda) ]; then
      printf "conda: Instalando pacote!\n"
      curl -O ${url["miniconda3"]}
      bash Miniconda3-py39_4.9.2-Linux-x86_64.sh -b -p ${prefix["miniconda3"]}
      rm Miniconda3-py39_4.9.2-Linux-x86_64.sh
      if [ -d "../conda-envs" ]; then
        for env in $(ls ../conda-envs/*.yaml);do
          conda env create -f $env
        done
      fi
    else
      printf "conda: Pacote já instalado!\n"
    fi
  fi

  if [ $1 == "*sublime" ]; then
    if [ -z $(which subl) ];then
      printf "sublime: Instalando pacote!\n"
      wget -qO - ${url["sublime"]} | sudo apt-key add -
      echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
      sudo apt-get update
      sudo apt-get install sublime-text
    else
      printf "sublime: Pacote já instalado!\n"
    fi
  fi

  if [ $1 == "*vscode" ]; then
    if [ -z $(which code) ];then
      printf "vscode: Instalando pacote!\n"
      wget ${url["vscode"]} 
      for deb in $(ls *.deb 2> /dev/null ); do
        if [[ "$deb" == *"code"* ]]; then
          sudo dpkg -r "$deb"
          sudo apt-get -f install > /dev/null
          rm "$deb"
        fi
      done
    else
      printf "vscode: Pacote já instalado!\n"
    fi
  fi  

}

main; exit
