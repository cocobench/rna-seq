import pandas as pd
from snakemake.remote import HTTP

https = HTTP.RemoteProvider()

configfile: "config.yaml"
samples = pd.read_table(config["samples"], index_col=0)

############# Helpers #######################

get_bam = lambda wildcards: samples.loc[wildcards.sample, "bam"]
get_fastq = lambda wildcards: samples.loc[wildcards.sample, ["fq1", "fq2"]]


############ Targets ########################

rule dataset:
    input:
        expand("subsampled/{sample}-{group}.R{read}.fastq.gz",
               sample=samples.index, read=[1,2], group=["A", "B"])


############# Generate dataset ##############

rule subsample:
    input:
        bam=get_bam,
        fastq=get_fastq,
        bed=config["subsampling"]["rates"],
        jar=os.path.join(os.path.dirname(workflow.snakefile),
                         "resources/DownsampleRegion-assembly-0.1-SNAPSHOT.jar")
    output:
        a=expand("subsampled/{{sample}}-A.R{read}.fastq.gz", read=[1, 2]),
        b=expand("subsampled/{{sample}}-B.R{read}.fastq.gz", read=[1, 2])
    params:
        sd=config["subsampling"]["sd"],
        seed=lambda wildcards: hash(wildcards.sample)
    conda:
        "envs/java.yaml"
    threads: 2
    shell:
        "java -jar {input.jar} --bamFile {input.bam} --bedFile {input.bed} "
        "--inputR1 {input.fastq[0]} --inputR2 {input.fastq[1]} "
        "--outputR1A {output.a[0]} --outputR2A {output.a[1]} "
        "--outputR1B {output.b[0]} --outputR2B {output.b[1]} "
        "--deviation {params.sd} --seed {params.seed}"


############# Metrics #######################

rule compare_count_tables:
    input:
        counts="results/{pipeline}/counts.tsv",
        truth="resources/known-counts.tsv"  # TODO we need to obtain these
    output:
        "metrics/{pipeline}-vs-truth.tsv"
    conda:
        "envs/r.yaml"
    script:
        "compareCountTables.R"
