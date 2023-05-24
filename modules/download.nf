#!/usr/bin/env nextflow
nextflow.enable.dsl=2


process downloadFiles {
  publishDir params.outputDir, mode: "copy"
  
  input:
    val id
    
  output:
    path("${id}**.fastq")

  script:
  """
  set -euo pipefail
  fasterq-dump --split-3 ${id} -t ./
  """
}


workflow download {

  take:

    accessions

  main:

    ids = Channel.fromList( accessions )
    downloadFiles(ids)
    
}