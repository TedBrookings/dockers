ARG PYTHON_VERSION=3.7.4
ARG ML_PYTHON_BASE_TAG=447c337
ARG CONDA_CUDNN_VERSION=7.6
ARG CONDA_INSTALL_PATH=/opt/miniconda

FROM ml_python_base:$ML_PYTHON_BASE_TAG

ARG CONDA_CUDNN_VERSION
ARG CONDA_INSTALL_PATH
ARG CONDA_INSTALLER=/root/miniconda_install.bin
ARG PYTORCH_GIT_PATH=/root/pytorch

LABEL maintainer="Ted Brookings <tbrookin@broadinstitute.org>"
ENV HOME=/root
ENV PATH=$CONDA_INSTALL_PATH/bin:$PATH
ENV LD_PATH=$LD_PATH:$CONDA_INSTALL_PATH/lib

# install conda and some basic non-gpu-based python packages
RUN wget  -q --show-progress --progress=dot:giga \
        https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
        -O $CONDA_INSTALLER \
    && /bin/bash $CONDA_INSTALLER -b -p $CONDA_INSTALL_PATH \
    && rm -f $CONDA_INSTALLER \
    && ln -s $CONDA_INSTALL_PATH/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". $CONDA_INSTALL_PATH/etc/profile.d/conda.sh" >> $HOME/.bashrc \
    && echo "CONDA_AUTO_ACTIVATE_BASE=false" >> $HOME/.bashrc \
    && /bin/bash $CONDA_INSTALL_PATH/etc/profile.d/conda.sh \
    && conda install -n base --force-reinstall conda \
    && conda update -n base -c defaults conda \
    && conda config --prepend channels conda-forge \
    && conda install -n base -y python=$PYTHON_VERSION \
    && conda install -n base -y --freeze-installed \
        seaborn matplotlib jupyter pytest pytest-cov sortedcontainers psutil \
        memory_profiler line_profiler scipy scikit-learn pandas dask pytables \
        intervaltree hyperopt autograd \
        cudnn=$CONDA_CUDNN_VERSION \
    && conda install -n base -y --freeze-installed -c bioconda \
        pybedtools pytabix pysam \
    && conda clean -ya

# build pytorch from source, install into conda env, and remove source
RUN DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y git \
    && conda install -n base -y --freeze-installed \
        ninja pyyaml mkl mkl-include typing \
    && dpkg -s nvidia-cuda-toolkit | grep '^Version' | awk -F'[ .]' '{print "magma-cuda"$2$3}'\
        | xargs conda install -n base -y --freeze-install -c pytorch \
    && git clone --recursive https://github.com/pytorch/pytorch $PYTORCH_GIT_PATH \
    && cd $PYTORCH_GIT_PATH \
    && CMAKE_PREFIX_PATH=$CONDA_INSTALL_PATH python setup.py install \
    && rm -r $PYTORCH_GIT_PATH \
    && conda remove -y ninja && conda clean -ya \
    && apt-get remove -y git && apt-get autoremove && apt-get clean


#    && conda run -n base pip install --no-cache-dir \
#        MulticoreTSNE phate pyro-ppl jax jaxlib tensorflow-gpu keras xgboost \

