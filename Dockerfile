FROM ubuntu:latest

MAINTAINER Oleg 'helgie' Lymarchuk (oleg.lymarchuk@icloud.com)

ARG LATESTSELENIUM
ARG LATESTCHROMEDRIVER

ENV SELENIUM /opt/selenium.jar
ENV CHROMEDRIVER /opt/chromedriver
ENV PATH "$PATH:/opt"

WORKDIR /tests

RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get -y upgrade && \
  apt-get update && \
  apt-get install -y \
  build-essential curl default-jre ffmpeg firefox git python3.5 python3.5-dev \
  python3-mysqldb python3.5-tk scrot sudo tmux wget unzip xvfb
RUN \
  wget -q https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1 && \
  python /tmp/get-pip.py
# RUN \
#   wget -q ${LATESTSELENIUM} -P /opt && \
#   mv /opt/* ${SELENIUM}
# RUN \
#   wget -q ${LATESTCHROMEDRIVER} -P /opt && \
#   unzip -q /opt/ch* -d /opt/ && \
#   rm /opt/*zip && \
  # chmod +x ${CHROMEDRIVER}
RUN \
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key \
  add - ; sh -c \ 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' ; \
  apt-get update ; exit 0
RUN \
  apt-get install -y google-chrome-stable
COPY \
  tests/requirements.txt /tests/requirements.txt
RUN \
  Xvfb :1 -screen 0 800x600x16 &> xvfb.log && \
  export DISPLAY=:1.0 && \
  touch /root/.Xauthority && \
  pip install image && \
  pip install python3-xlib && \
  pip install bpython && \
  pip install -r /tests/requirements.txt ; \
  mkdir /Screenshots ; \
  chmod 777 -R /Screenshots

CMD \
  Xvfb :2 -listen tcp -screen 0 1366x1000x24+32 -fbdir /var/tmp&  \
  export DISPLAY=:2.0 && \
  tmux new-session -d -s pyTestRecording "ffmpeg -f x11grab -video_size 1366x1000 -i 127.0.0.1:2 -codec:v libx264 -r 12 Screenshots/out$(date +"%I_%M_%S").mkv" && \
  py.test -s $TEST
