FROM node:current-buster
LABEL maintainer=heywoodlh

ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y ca-certificates git vim less nano pandoc ripgrep w3m tig lsb-release &&\
	rm -rf /var/lib/apt/lists/*

COPY ./nb /usr/local/bin/nb

RUN chmod +x /usr/local/bin/nb
RUN yes | nb env install &&\
	rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash nb
RUN passwd -d nb

USER nb
WORKDIR /home/nb

ENTRYPOINT ["nb"]
CMD ["help"]
