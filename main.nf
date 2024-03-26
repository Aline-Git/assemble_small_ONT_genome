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
process UNZIP_INPUT {
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
process MERGE_FASTQ {

  publishDir params.outdir, mode: 'copy'

  input:
    path input_file
  
  output:
    path "${params.SEQ_ID}_pass_all.fastq"
  
  script:
  """
  cat $input_file >> ${params.SEQ_ID}_pass_all.fastq
  """
}



/*
 * define the `trim_adapters` process that trims the adapters
 * works but can be refined
 */
process TRIM_ADAPTERS  {
tag '***  1. trim adapters with porechop ***'

// mkdir $OUTPUT/adapter_cut

//replace the seqID
  input:
  path "${params.SEQ_ID}_pass_all.fastq"
  
  // essayer d'ajouter params.seqID
  output:
  path "${params.SEQ_ID}_porechoped.fastq"

  script:
  """
  porechop_abi -abi --no_split -t 1 \
  -i ${params.SEQ_ID}_pass_all.fastq \
  -o ${params.SEQ_ID}_porechoped.fastq 
  rm -r tmp
  """
}


/*
 * define the `MAP_READS_AVA` process that maps the reads on themselves
 */
process MAP_READS_AVA  {
tag '***  removes chimeric part of reads if any ***'

  input:
  path "${params.SEQ_ID}_*.fastq"
  
  output:
  path "${params.SEQ_ID}_ava_overlap.paf"

  script:
  """
  minimap2 -x ava-ont -g 500 \
  ${params.SEQ_ID}_porechoped.fastq \
  ${params.SEQ_ID}_porechoped.fastq \
  > ${params.SEQ_ID}_ava_overlap.paf
 
  """
}


/*
 * define the `FILTER_CHIMERA` process that trims the chimeric parts of reads
 */
process FILTER_CHIMERA  {
tag '***  removes chimeric part of reads if any ***'

  input: 
  path "${params.SEQ_ID}_*.fastq"
  path "${params.SEQ_ID}_ava_overlap.paf"
  
  output:
  path "${params.SEQ_ID}_porechoped_ctrimed.fastq"
  path "${params.SEQ_ID}_reads.yacrd"
  
  script:
  """
  yacrd -i ${params.SEQ_ID}_ava_overlap.paf \
  -o ${params.SEQ_ID}_reads.yacrd \
  filter -i ${params.SEQ_ID}_porechoped.fastq \
  -o ${params.SEQ_ID}_porechoped_ctrimed.fastq
  """
}


/*
 * for the moment the workflow unzip the raw input files and merge them into one fastq file
 */
workflow {

    raw_input_ch = Channel.fromPath( "/home/aline/raw_data/our_data/Pichia/${params.SEQ_ID}/*.fastq.gz" )
    unziped_ch = UNZIP_INPUT(raw_input_ch).collect()
    merged_input_ch = MERGE_FASTQ(unziped_ch)
	adapter_trimmed_ch = TRIM_ADAPTERS(merged_input_ch)
	ava_overlap_ch = MAP_READS_AVA(adapter_trimmed_ch)
	
	

}
























