# ![wf-ani](images/wf-ani_logo_light.png#gh-light-mode-only) ![wf-ani](images/wf-ani_logo_dark.png#gh-dark-mode-only)

![workflow](images/workflow_v1.0.0.svg)

_A schematic of the steps in the workflow._

## Requirements

- [`Nextflow`](https://www.nextflow.io/docs/latest/getstarted.html#installation) (`>=22.04.3`)
- [`Docker`](https://docs.docker.com/engine/installation/) or [`Singularity >=3.8.0`](https://www.sylabs.io/guides/3.0/user-guide/)

## Install on our HPC

```
git clone https://github.com/gregorysprenger/wf-ani.git $LAB_HOME/workflows
```

## Setup Singularity environment variables - For Aspen Cluster

```
# Add to $HOME/.bashrc
SINGULARITY_BASE=/scicomp/scratch/$USER

export SINGULARITY_TMPDIR=$SINGULARITY_BASE/singularity.tmp

export SINGULARITY_CACHEDIR=$SINGULARITY_BASE/singularity.cache

export NXF_SINGULARITY_CACHEDIR=$SINGULARITY_BASE/singularity.cache

mkdir -pv $SINGULARITY_TMPDIR $SINGULARITY_CACHEDIR
```

Reload .bashrc

```
source ~/.bashrc
```

# Run Workflow

Before running workflow on new data, the workflow should be ran on the built-in test data to make sure everything is working properly. It will also download all dependencies to make subsequent runs much faster.

```
cd $LAB_HOME/workflows/wf-ani

module load nextflow

nextflow run main.nf \
  -profile singularity,test
```

To minimize typing all of the parameters above, a bash script was created for UGE HPCs. It can take FastA/Genbank files from selected directory OR if FastA/Genbank files not found in that directory, it will look in subdirectories for FastA/Genbank files. To run:

```
run_ANIb_ALL_vs_ALL.uge-nextflow INPUT_DIRECTORY
```

Example analysis using Nextflow command:

```
nextflow run main.nf \
  -profile singularity \
  --input INPUT_DIRECTORY \
  --outdir OUTPUT_DIRECTORY
```

Help menu of all options:

```
nextflow run main.nf --help
```