# For testing vim-colortemplate:
FROM ubuntu:18.04
RUN apt-get update && apt-get -y install vim
COPY . /vim-colortemplate
