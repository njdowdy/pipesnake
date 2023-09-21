process IQTREE {
    tag "$fasta"

    conda "bioconda::iqtree=2.1.4_beta"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/iqtree:2.2.5--h21ec9f0_0' :
        'biocontainers/iqtree:2.2.5--h21ec9f0_0' }"

    input:
    val(fasta_ls)
    
    output:
    path("*.contree"), emit: contree
    path("*.iqtree"), emit: iqtree
    path("*.log"), emit: log
    path("*.ckp.gz"), emit: ckp
    path("*.treefile"), emit: treefile
    path("*.splits.nex"), emit: splits
    path("*.bionj"), emit: bionj
    path("*.mldist"), emit: mldist
    path("*.model.gz"), emit: modle
    path "versions.yml", emit: versions

    script:
    //locus = fasta.getBaseName().split('.')[0]
    
    """
     for fasta in ${fasta_ls.join(' ')}; do
        file_lines=\$(cat \$fasta | wc -l)
        if [ \$file_lines -gt 0 ]
        then
            sp_cnt=\$(cat \$fasta | grep \\> | wc -l)
            if [ \$sp_cnt -lt 4 ]
            then
                echo "\$fasta" >> fasta_few_specieis.txt
            else
                iqtree -s \${fasta} -T ${task.cpus} ${task.ext.args} -pre \$(basename "\$fasta")
            fi
        else
            echo "\$fasta" >> empty_fastq.txt
        fi       
    done

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iqtree: \$( iqtree --version | sed -n '1 p')
    END_VERSIONS
    """
}
