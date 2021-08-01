FROM ubuntu:20.04 AS base

LABEL image python-r-base

################ VARIABLES ################

# Environment variables available only at build time
ARG DEBIAN_FRONTEND=noninteractive

# Environment variables always available
ENV TZ=America/New_York
ENV LANG C.UTF-8

ENV R_GPG_KEY E298A3A825C0D65DFD57CBB651716619E084DAB9

ENV PYTHON_GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.8.11
ENV PYTHON_PIP_VERSION 21.1.3
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/a1675ab6c2bd898ed82b1f58c486097f763c74a9/public/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6665659241292b2147b58922b9ffe11dda66b39d52d8a6f3aa310bc1d60ea6f7
ENV PYTHON_POETRY_VERSION 1.1.6

################ BASE REQUIREMENTS ################

# Install base packages
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y \
    	curl \
		gnupg \
		sudo \
        wget \
    && apt-get update -y \
    && apt-get install -y \
        vim \
        software-properties-common \
        libssl-dev \
        libcurl4-openssl-dev \
        libxml2-dev \
        libbluetooth-dev \
        tk-dev \
        uuid-dev \
        libspatialindex-dev \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

################ R ################

# Install base R
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${R_GPG_KEY}"
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
RUN apt-get update -y \
    && apt-get install -y \
    	r-base \
        jags \
    && rm -rf /var/lib/apt/lists/*

################ PYTHON ################
# Mainly ganked from https://github.com/docker-library/python/blob/dbf2083938bd54ddb0f8697c177d5ccfc927f20f/3.8/buster/Dockerfile

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

RUN set -ex \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "${PYTHON_GPG_KEY}" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
			-o \( -type f -a -name 'wininst-*.exe' \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

RUN set -ex; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py


################ POST INSTALLATION ################

# Install user yogi
RUN adduser yogi --disabled-password \
    && usermod -aG sudo yogi \
    && echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && echo "Set disable_coredump false" >> /etc/sudo.conf

USER yogi

WORKDIR /home/yogi
RUN mkdir -p /home/yogi/.R/lib
ENV R_LIBS="/home/yogi/.R/lib"

# Install R requirements
COPY --chown=yogi:yogi renv.lock .Rprofile /home/yogi/
COPY --chown=yogi:yogi renv/activate.R /home/yogi/renv/activate.R
RUN Rscript -e 'if(!requireNamespace("remotes")){install.packages("remotes");remotes::install_github("rstudio/renv")} else {remotes::install_github("rstudio/renv")}' \
    && Rscript -e 'renv::restore()'

# Install python requirements
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/48339106eb0d403a3c66519317488c8185844b32/install-poetry.py --output /tmp/install-poetry.py \
    && python3 /tmp/install-poetry.py --yes --version=${PYTHON_POETRY_VERSION}
COPY --chown=yogi:yogi pyproject.toml poetry.lock /home/yogi/
COPY --chown=yogi:yogi src /home/yogi/src/
RUN poetry install

CMD ["bash"]
