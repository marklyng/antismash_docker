
FROM mambaorg/micromamba:2.0.8-ubuntu22.04 AS app

ARG ANTISMASH_VER="8.0.1"

# 'LABEL' instructions tag the image with metadata that might be important to the user
LABEL base.image="ubuntu:jammy"
LABEL dockerfile.version="1"
LABEL software="antiSMASH"
LABEL software.version="${ANTISMASH_VER}"
LABEL description="the antibiotics and Secondary Metabolite Analysis SHell"
LABEL website="https://antismash.secondarymetabolites.org/#!/about"
LABEL license="https://antismash.secondarymetabolites.org/#!/about"
LABEL maintainer.image="Mark Lyng"
LABEL maintainer.image.email="ml@nordicmicrobes.dk"

USER root

# 'RUN' executes code during the build
# Install dependencies via apt-get or yum if using a centos or fedora base
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    ca-certificates \
    && apt-get autoclean && rm -rf /var/lib/apt/lists/*

ENV PATH="/opt/conda/bin:$PATH" \
    LC_ALL=C

RUN micromamba install --name base -c conda-forge -c bioconda antismash=${ANTISMASH_VER} && \
    download-antismash-databases && \
    micromamba clean -a -f -y && \
    mkdir /data

CMD ["antismash", "--help"]

WORKDIR /data

FROM app AS test

WORKDIR /test

RUN antismash --help && \
    antismash --version

RUN micromamba list
