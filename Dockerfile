ARG UBUNTU_VERSION=22.04
FROM ubuntu:${UBUNTU_VERSION} AS builder

ARG UBUNTU_VERSION=${UBUNTU_VERSION}
ARG CKAN_REF=dev-v2.11
ARG DATAPUSHER_VERSION=0.0.21
ARG ITERATION

# Install Ubuntu packages
RUN apt-get update -q && \
    apt-get upgrade -y -q && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y -q install \
        lsb-release \
        git \
        python3-dev \
        python3-pip \
        python3-venv \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        build-essential \
        rubygems-integration \
        ruby-dev \
        nginx

# Install FPM
RUN if [ "$UBUNTU_VERSION" = "20.04" ] ; then gem install dotenv -v 2.8.1 ; fi && \
    gem install fpm -- creates=/usr/local/bin/fpm

# Create dirs
RUN mkdir -p /etc/ckan/default && \
    mkdir -p /etc/ckan/datapusher && \
    mkdir -p /etc/supervisor/conf.d && \
    mkdir /output

# Create venv
RUN python3 -m venv /usr/lib/ckan/default

# Pull CKAN source
RUN git clone --depth=1 --branch=${CKAN_REF} https://github.com/ckan/ckan /usr/lib/ckan/default/src/ckan && \
    rm -rf /usr/lib/ckan/default/src/ckan/.git/

# Install CKAN and its requirements
RUN /usr/lib/ckan/default/bin/pip install -U pip && \
    /usr/lib/ckan/default/bin/pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt uwsgi && \
    /usr/lib/ckan/default/bin/pip install /usr/lib/ckan/default/src/ckan

# Configure CKAN + uWSGI
RUN cp /usr/lib/ckan/default/src/ckan/wsgi.py /etc/ckan/default/wsgi.py && \
    cp /usr/lib/ckan/default/src/ckan/ckan-uwsgi.ini /etc/ckan/default/ckan-uwsgi.ini

# Install DataPusher
RUN python3 -m venv /usr/lib/ckan/datapusher && \
    # Clone source
    git clone --depth=1 --branch=${DATAPUSHER_VERSION} https://github.com/ckan/datapusher /usr/lib/ckan/datapusher/src/datapusher && \
    rm -rf /usr/lib/ckan/datapusher/src/datapusher/.git/ && \
    # Install requirements and datapusher
    /usr/lib/ckan/datapusher/bin/pip install -U pip && \
    /usr/lib/ckan/datapusher/bin/pip install -r /usr/lib/ckan/datapusher/src/datapusher/requirements.txt uwsgi && \
    /usr/lib/ckan/datapusher/bin/pip install /usr/lib/ckan/datapusher/src/datapusher

# Configure DataPusher + uWSGI
RUN cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher.wsgi /etc/ckan/datapusher && \
    cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher_settings.py /etc/ckan/datapusher && \
    cp /usr/lib/ckan/datapusher/src/datapusher/deployment/datapusher-uwsgi.ini /etc/ckan/datapusher && \
    # Enable threads in DataPusher uwsgi conf
    echo "workers = 2\nthreads = 2\nlazy-apps = true" >> /etc/ckan/datapusher/datapusher-uwsgi.ini && \
    # Replace datapusher wsgi file path
    sed -i 's/\/usr\/lib\/ckan\/datapusher\/src\/datapusher\/deployment\/datapusher.wsgi/\/etc\/ckan\/datapusher\/datapusher.wsgi/g' /etc/ckan/datapusher/datapusher-uwsgi.ini

# Copy conf files
COPY common/etc/nginx/sites-available/ckan /etc/nginx/sites-available/
COPY common/etc/cron.daily/remove_old_sessions /etc/cron.daily/
COPY common/etc/supervisor/conf.d/ckan-uwsgi.conf /etc/supervisor/conf.d/
COPY common/etc/supervisor/conf.d/ckan-worker.conf /etc/supervisor/conf.d/
COPY common/etc/supervisor/conf.d/ckan-datapusher.conf /etc/supervisor/conf.d/
COPY --chmod=744 common/usr/bin/ckan /usr/bin/ckan
COPY --chmod=744 common/after_web.sh /tmp/after_web.sh

# Get the actual CKAN version and create the deb package
RUN DISTRIBUTION=$(lsb_release -c -s) && \
    CKAN_VERSION=$(/usr/lib/ckan/default/bin/python3 -c "import ckan; print(ckan.__version__)") && \
    fpm \
    -t deb -s dir \
    --package /output \
    --name python-ckan \
    --description='CKAN is an open-source DMS (data management system) for powering data hubs and data portals.' \
    --license='AGPL v3.0' \
    --maintainer='CKAN Tech Team <tech-team@ckan.org>' \
    --vendor='CKAN Association' \
    --url='https://ckan.org' \
    --after-install=/tmp/after_web.sh \
    --iteration "$DISTRIBUTION""${ITERATION}" \
    --version "$CKAN_VERSION" \
    --depends nginx \
    --depends libpq5 \
    --config-files /etc/nginx/sites-available/ckan \
            /usr/lib/ckan/ \
            /etc/ckan/ \
            /usr/bin/ckan \
            /etc/cron.daily/remove_old_sessions  \
            /etc/nginx/sites-available/ckan \
            /etc/supervisor/conf.d

RUN ls -la /output

FROM scratch AS export
COPY --from=builder /output .
