# Initial Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Original file from https://github.com/jupyter/docker-stacks/blob/master/datascience-notebook/Dockerfile
# Modified by Charles Le Losq to offer more Julia facilities out of the box.
# Removing the R framework also. Try the docker container from Jupyter if you want R!

FROM jupyter/scipy-notebook

MAINTAINER Jupyter Project <jupyter@googlegroups.com>

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    gfortran \
    gcc && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_PKGDIR=/opt/julia

RUN echo "deb http://ppa.launchpad.net/staticfloat/juliareleases/ubuntu trusty main" > /etc/apt/sources.list.d/julia.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3D3D3ACC && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    julia \
    libnettle4 && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Show Julia where conda libraries are \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /usr/etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown -R $NB_USER:users $JULIA_PKGDIR

USER $NB_USER

# Add Julia packages
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'Pkg.init()' && \
    julia -e 'Pkg.update()' && \
    julia -e 'Pkg.add("HDF5")' && \
    julia -e 'Pkg.add("Gadfly")' && \
	julia -e 'Pkg.add("Convex")' && \
    julia -e 'Pkg.add("RDatasets")' && \
    julia -e 'Pkg.add("IJulia")' && \
    julia -e 'Pkg.add("Ipopt")' && \
    julia -e 'Pkg.add("JuMP")' && \
    julia -e 'Pkg.add("Spectra")' && \
    julia -e 'Pkg.add("SQLite")' && \
    julia -e 'Pkg.add("LsqFit")' && \
    julia -e 'Pkg.add("Optim")' && \
    julia -e 'Pkg.add("NMF")' && \
    julia -e 'Pkg.add("DataFrames")' && \
    julia -e 'Pkg.add("JLD")' && \
    julia -e 'Pkg.add("Plots")' && \
    julia -e 'Pkg.add("PyCall")' && \
    julia -e 'Pkg.add("PyPlot")' && \
    julia -e 'Pkg.add("ExcelReaders")' && \
    julia -e 'Pkg.add("Dierckx")' && \
    julia -e 'Pkg.add("ProgressMeter")' && \
    # Updating everything
    julia -e 'Pkg.update()' && \
    # Precompile Julia packages \
    julia -e 'using HDF5' && \
    julia -e 'using Gadfly' && \
    julia -e 'using RDatasets' && \
    julia -e 'using IJulia' && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local
