FROM ubuntu:focal
RUN apt update

# USER root

# Set timezone 
RUN DEBIAN_FRONTEND=noninteractive apt install tzdata
ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localyime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Set kubectl
RUN apt install -y bash curl jq wget vim

RUN mkdir /alertmaker

WORKDIR /alertmaker

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN mv kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl

COPY ./gettoken.sh ./gettoken.sh
RUN chmod +x ./gettoken.sh

# RUN ./gettoken.sh

# CMD /alertmaker/gettoken.sh

CMD bash