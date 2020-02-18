ARG PYTHON_VERSION=3.7.4
ARG WITH_TORCHVISION=true
ARG ML_PYTHON_BASE_TAG=latest
ARG CONDA_INSTALL_PATH=/opt/conda

FROM tedbrookings/ml_python_base:$ML_PYTHON_BASE_TAG

ARG CONDA_INSTALL_PATH
ARG CONDA_INSTALLER=/root/miniconda_install.bin
ARG PYTORCH_GIT_PATH=/opt/pytorch
ARG TENSORFLOW_GIT_PATH=/opt/tensorflow

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
    && conda install -n base -y --freeze-installed -c bioconda \
        pybedtools pytabix pysam \
    && conda clean -ya

# build pytorch from source, install into conda env, and remove source
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        libjpeg-dev libpng-dev \
    && apt-get autoremove && apt-get clean \
    && conda install -n base -y --freeze-installed \
        ninja pyyaml mkl mkl-include typing \
    && nvcc -V | grep -oP "(?<=release )[^ ,]+" | awk -F. '{print "magma-cuda"$1$2}' \
        | xargs conda install -n base -y --freeze-install -c pytorch \
    && git clone --recursive https://github.com/pytorch/pytorch $PYTORCH_GIT_PATH \
    && cd $PYTORCH_GIT_PATH \
    && TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" \
        TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
        CMAKE_PREFIX_PATH=$CONDA_INSTALL_PATH \
        python setup.py install \
    && if $WITH_TORCHVISION; then \
            git clone https://github.com/pytorch/vision.git \
            && cd vision \
            && TORCH_CUDA_ARCH_LIST="3.5 5.2 6.0 6.1 7.0+PTX" \
                TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
                CMAKE_PREFIX_PATH=$CONDA_INSTALL_PATH \
                python setup.py install ; \
       else \
            echo "building without torchvision" ; \
       fi \
    && cd $HOME && rm -r $PYTORCH_GIT_PATH \
    && conda remove -y ninja && conda clean -ya

[ *** NOTE *** there are unfinished changes in this file !!! ]
# build tensorflow from source, install into conda env, and remove source
RUN sudo apt install python3-dev python3-pip \
    && conda run -n base pip install --no-cache-dir \
        six numpy wheel setuptools mock 'future>=0.17.1' \
    && conda run -n base pip install --no-cache-dir --no-deps \
        keras_applications keras_preprocessing \
    && [install bazel]
    && git clone https://github.com/tensorflow/tensorflow.git $TENSORFLOW_GIT_PATH \
    && cd $TENSORFLOW_GIT_PATH \
    && ./configure [need to make this non-interactive, there are preconfigured bazel builds???]
    && bazel build //tensorflow/tools/pip_package:build_pip_package
    
    
    && cd $HOME && rm -r $TENSORFLOW_GIT_PATH
    && [uninstall bazel]

#    && conda run -n base pip install --no-cache-dir \
#        MulticoreTSNE phate pyro-ppl jax jaxlib tensorflow-gpu keras xgboost \

