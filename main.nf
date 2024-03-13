#!/usr/bin/env nextflow
 
params.SEQ_ID = "L67_APT515_test"

process unzip_input {

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


process merge_fastq {
  debug true   
  input:
  path input_file
  
  output:
  path "seqID_pass_all.fastq"
  
  script:
  """
  cat $input_file >> seqID_pass_all.fastq
  """
}

workflow {

    Channel.fromPath( "/home/aline/raw_data/our_data/Pichia/${params.SEQ_ID}/*.fastq.gz" ) | unzip_input
//	| collectFile \
	| merge_fastq | collectFile

}




