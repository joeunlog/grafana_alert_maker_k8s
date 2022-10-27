FROM ubuntu:focal
RUN apt update

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

COPY ./gettoken.sh .
RUN chmod 777 ./gettoken.sh
# RUN /tmp/gettoken.sh

CMD /tmp/gettoken.sh