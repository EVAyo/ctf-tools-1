FROM ubuntu:noble

# wrapper script for apt-get
COPY .docker/apt-get-install /usr/local/bin/apt-get-install
RUN chmod +x /usr/local/bin/apt-get-install

RUN apt-get-install build-essential libtool g++ gcc rubygems \
    texinfo curl wget automake autoconf python3 python3-dev git \
    unzip virtualenvwrapper sudo git subversion virtualenvwrapper ca-certificates

RUN useradd -m ctf
RUN echo "ctf ALL=NOPASSWD: ALL" > /etc/sudoers.d/ctf

COPY .git /home/ctf/tools/.git
RUN chown -R ctf:ctf /home/ctf/tools

# git checkout of the files
USER ctf
WORKDIR /home/ctf/tools
RUN git checkout .

# add non-commited scripts
USER root
COPY bin/manage-tools /home/ctf/tools/bin/
RUN chown -R ctf:ctf /home/ctf/tools

# finally run ctf-tools setup
USER ctf
RUN bin/manage-tools -s setup

ARG PREINSTALL=""
RUN <<END
for TOOL in $PREINSTALL
do
	/home/ctf/tools/bin/manage-tools -s -v install $TOOL
done
END

WORKDIR /home/ctf
