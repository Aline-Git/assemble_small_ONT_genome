#!/usr/bin/env nextflow

/* 
 * pipeline input parameters
 */
 
params.SEQ_ID = "L67_APT515_test"
// here the paths are relative to the one the workflow is launched
params.outdir = "test_results"

// this part will be printed at the beginning of the run
log.info """\
    R N A S E Q - N F   P I P E L I N E
    ===================================
    sequenceID   : ${params.SEQ_ID}
    reads        : to complete
    outdir       : to complete
	"""
	.stripIndent(true)
	
	
/*
 * define the `unzip_input` process that unzip a gziped input file
 */
process unzip_input {
    tag "unzip input files"
    stageInMode 'copy'
	
    input: 
		path zip_input
	
    output:
        path "*.fastq"

    script:
    """
    gzip -d $zip_input 
	
    """
}
  
  
/*
 * define the `merge_fastq` process that merges multiple ouput files
 */
process merge_fastq {

  publishDir params.outdir, mode: 'copy'

  input:
    path input_file
  
  output:
    path "seqID_pass_all.fastq"
  
  script:
  """
  cat $input_file >> seqID_pass_all.fastq
  """
}


/*
 * for the moment the workflow unzip the raw input files and merge them into one fastq file
 */
workflow {

    raw_input_ch = Channel.fromPath( "/home/aline/raw_data/our_data/Pichia/${params.SEQ_ID}/*.fastq.gz" )
    unziped_ch = unzip_input(raw_input_ch).collect()
    merge_fastq(unziped_ch)

}
























