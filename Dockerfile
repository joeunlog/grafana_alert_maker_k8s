FROM ubuntu:focal
RUN apt update

# Set timezone 
RUN DEBIAN_FRONTEND=noninteractive apt install tzdata
ENV TZ Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localyime && echo $TZ > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

# Set kubectl
RUN apt install -y bash curl jq wget vim

CMD bash