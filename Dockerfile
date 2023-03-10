FROM ubuntu:22.10

LABEL description="Docker image for the Robot Framework"
LABEL usage=" "

# Set timezone to America/Sao_Paulo and install dependencies
#   * git & curl & wget
#   * python3
#   * xvfb
#   * chrome
#   * chrome selenium driver
#   * hi-res fonts

ENV DEBIAN_FRONTEND noninteractive

# Create user
RUN useradd automation --shell /bin/bash --create-home

RUN apt-get -yqq update \
    && apt-get install -y software-properties-common \

#install pip3 and python3 + libraries
    && apt-get install -y python3 python3-pip python3-venv \
    && apt-get install -y python3-gi gobject-introspection gir1.2-gtk-3.0 \

#install basic programs and correct time zone:
    apt-utils \
    sudo \
    tzdata \
    xvfb \
    git \
    unzip \
    wget \
    curl \
    dbus-x11 \
    xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
    --no-install-recommends \
    && apt-get clean autoclean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && echo "America/Sao_Paulo" > /etc/timezone \
    && rm /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \

#install google chrome latest version
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get -yqq update \
    && apt-get -yqq install google-chrome-stable \
    && rm -rf /var/lib/apt/lists/* \
    && chmod a+x /usr/bin/google-chrome \

#install chromedriver based on the chrome-version (compatible chromedriver and chrome has same main version number)
    && CHROME_VERSION=$(google-chrome --version) \
    && MAIN_VERSION=${CHROME_VERSION#Google Chrome } && MAIN_VERSION=${MAIN_VERSION%%.*} \
    && echo "main version: $MAIN_VERSION" \
    && CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE_$MAIN_VERSION` \
    && echo "**********************************************************" \
    && echo "chrome version: $CHROME_VERSION" \
    && echo "chromedriver version: $CHROMEDRIVER_VERSION" \
    && echo "**********************************************************" \
    && mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION \
    && echo "directory for chromedriver set: /opt/chromedriver-$CHROMEDRIVER_VERSION" \
    && curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
    && unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION  \
    && rm /tmp/chromedriver_linux64.zip \
    && echo "chromedriver copied to directory" \
    && chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver \
    && echo "original file: /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver" \
    && echo "linked to file: /usr/local/bin/chromedriver" \
    && ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver

# Fix hanging Chrome, see https://github.com/SeleniumHQ/docker-selenium/issues/87
ENV DBUS_SESSION_BUS_ADDRESS /dev/null

# Configure monitor
ENV DISPLAY :20.0
ENV SCREEN_GEOMETRY "1366x768x24"
# Configure chromedriver
ENV CHROMEDRIVER_PORT 4444
ENV CHROMEDRIVER_WHITELISTED_IPS "127.0.0.1"
ENV CHROMEDRIVER_URL_BASE ''
ENV CHROMEDRIVER_EXTRA_ARGS ''

EXPOSE 4444

# Install Robot Framework libraries
COPY requirements.txt /tmp/
RUN pip3 install -Ur /tmp/requirements.txt && rm /tmp/requirements.txt

ADD run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

CMD ["run.sh"]
