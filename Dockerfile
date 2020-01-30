#=================================================================================
#
# Create a docker image for ESMValTool that can be used in combination with
# the Nird Toolkit application : jupyter notebook
#
#=================================================================================
# Create a docker image based on a uninett base image
# See the value of dockerImage in
#
#   https://github.com/Uninett/helm-charts/blob/master/repos/stable/jupyter/values.yaml
#   https://quay.io/repository/uninett/jupyter-spark?tab=tags
#
# to determine the latest base image
#=================================================================================

FROM quay.io/uninett/jupyterhub-singleuser:20191012-5691f5c

LABEL maintainer=" Tomas Torsvik <tomas.torsvik@uib.no>"  \
      version="1.0.4"

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

#=================================================================================
# Install ESMValTool
# Based on:
#  https://github.com/ESMValGroup/ESMValTool/blob/version2_development/docker/Dockerfile
#=================================================================================

# Update root environment and conda packages
USER root
RUN apt-get update && apt-get install -y vim
RUN conda update -y conda pip

# create "esmvaltool" environment
RUN conda env create -f environment.yml

RUN source activate esmvaltool && \
    /opt/conda/bin/ipython kernel install --user --name esmvaltool && \
    /opt/conda/bin/python -m ipykernel install --user --name=esmvaltool && \
    /opt/conda/bin/jupyter labextension install @jupyterlab/hub-extension \
                           @jupyter-widgets/jupyterlab-manager && \
    /opt/conda/bin/jupyter labextension install jupyterlab-datawidgets && \
    /opt/conda/bin/jupyter labextension install @jupyter-widgets/jupyterlab-sidecar && \
    /opt/conda/bin/jupyter labextension install @pyviz/jupyterlab_pyviz \
                           jupyter-leaflet

# Fix hub failure
RUN fix-permissions $HOME

# Install other packages
USER notebook
ENV PATH="~/.local/bin:${PATH}"
