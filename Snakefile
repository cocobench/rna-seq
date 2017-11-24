import pandas as pd

samples = pd.read_table("samples.tsv", index_col=0)


############# Generate dataset ##############

rule dataset:
    input:
        expand("downsampled/{sample}.R{read}.fastq", sample=samples, read=[1,2])


rule subsample:
    input:
        bam=get_bam,
        fastq=get_fastq,
        bed=config["subsampling"]["rates"]
    output:
        a=expand("subsampled/{{sample}}-A.R{read}.fastq", read=[1, 2]),
        b=expand("subsampled/{{sample}}-B.R{read}.fastq", read=[1, 2])
    params:
        sd=config["subsampling"]["sd"],
        seed=lambda wildcards: hash(wildcards.sample)
    shell:
        "java -jar --bamFile {input.bam} --bedFile {input.bed} "
        "--inputR1 {input.fastq[0]} --inputR2 {input.fastq[1]} "
        "--outputR1A {output.a[0]} --outputR2A {output.a[1]} "
        "--outputR1B {output.b[0]} --outputR2B {output.b[1]} "
        "--deviation {params.sd} --seed {params.seed}"
