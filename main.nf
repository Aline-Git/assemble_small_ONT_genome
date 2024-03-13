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



workflow {

    Channel.fromPath( "/home/aline/raw_data/our_data/Pichia/${params.SEQ_ID}/*.fastq.gz" ) | unzip_input
	//| collectFile \
	| view

}




