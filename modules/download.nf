#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.args_sra = ''

process downloadFiles {
  tag "$id"
  publishDir params.outputDir, mode: "copy"

  container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
      'https://depot.galaxyproject.org/singularity/mulled-v2-5f89fe0cd045cb1d615630b9261a1d17943a9b6a:6a9ff0e76ec016c3d0d27e0c0d362339f2d787e6-0' :
      'biocontainers/mulled-v2-5f89fe0cd045cb1d615630b9261a1d17943a9b6a:6a9ff0e76ec016c3d0d27e0c0d362339f2d787e6-0' }"
  
  input:
    val id
    
  output:
    path("${id}**.fastq.gz")

  script:
  args = params.args_sra
  """
  set -euo pipefail
  prefetch $id

  fasterq-dump \\
        $args \\
        --threads $task.cpus \\
        --split-3 \\
        $id/${id}.sra

  pigz \\
      --no-name \\
      --processes $task.cpus \\
      *.fastq

  """
  // -t $workflow.workDir \\
  // #vdb-config --interactive
}


workflow download {

  take:

    accessions

  main:

    ids = Channel.fromList( accessions )
    downloadFiles(ids)
    
}