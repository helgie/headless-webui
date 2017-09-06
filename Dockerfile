FROM ubuntu:latest

ENV CHROME="\
  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

ENV CHROMEDRIVER="\
https://chromedriver.storage.googleapis.com/2.31/chromedriver_linux64.zip"

ENV PACKAGES="\
  curl \
  ffmpeg \
  fonts-liberation \
  gconf-service \
  git \
  libappindicator1 \
  libatk1.0-0 \
  libcairo2 \
  libcups2 \
  libgconf-2-4 \
  libgdk-pixbuf2.0-0 \
  libgtk-3-0 \
  libnspr4 \
  libnss3 \
  libpango-1.0-0 \
  libxss1 \
  lsb-release \
  python3.5 \
  scrot \
  tmux \
  unzip \
  wget \
  xdg-utils \
  xvfb \
"

ENV REQUIREMENTS="\
  pyScreeze \
  pytest \
  selenium \
"

RUN \
apt-get update && \
apt-get install -y ${PACKAGES} && \
apt-get autoremove

RUN \
  curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py -s && \
  update-alternatives --install /usr/bin/python python /usr/bin/python3.5 1 && \
  python /tmp/get-pip.py && pip install $REQUIREMENTS

RUN \
  curl ${CHROME} -o chrome.deb -s ; \
  dpkg -i chrome.deb && \
  rm chrome.deb

RUN \
  curl -s -o chromedriver.zip ${CHROMEDRIVER} ; \
  unzip -q chromedriver -d /usr/local/bin && rm chromedriver.zip ;

CMD \
  Xvfb :$(hostname -i | sed s/.*\0.//) -listen tcp -screen 0 1280x720x24+32 \
  -fbdir /var/tmp& \
  export DISPLAY=:$(hostname -i | sed s/.*\0.//) ; \
  ffmpeg -f x11grab -video_size 1280x720 -i 127.0.0.1${DISPLAY} -codec:v \
  libx264 -r 12 /tests/Screenshots/$(hostname)$(date +"%I_%M_%S").mkv > \
  /dev/null 2>/dev/null & py.test -s $TEST ; sleep 5  

