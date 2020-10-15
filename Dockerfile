FROM ubuntu
LABEL maintainer=heywoodlh

ENV TERM=xterm-256color
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ca-certificates git vim less nano pandoc ripgrep w3m tig lsb-release nodejs npm wget &&\
	rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app
RUN chmod +x /app/nb && ln -s /app/nb /usr/local/bin/nb

RUN nb env install &&\
	rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash nb
RUN passwd -d nb

USER nb
WORKDIR /home/nb

ENTRYPOINT ["nb"]
CMD ["help"]
