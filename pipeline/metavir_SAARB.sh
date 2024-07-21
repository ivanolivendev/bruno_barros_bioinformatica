#!/bin/bash
echo -e "Virome pipeline - cleaning and mounting genome"
echo -e "by Sandro Patroca, 2018-07-19\n"

mkdir 01_RawData 02_Clean_RawData 04_Assembler_spades
mv *.gz 01_RawData
gunzip 01_RawData/*.gz

echo -e "Cleaning - remove rRNA\n"
/opt/01_Assembly/sortmerna-2.1b/scripts/merge-paired-reads.sh 01_RawData/*.fastq 01_RawData/OUTPUT_FILE_merge.fastq
sortmerna --ref /opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-bac-16s-id90.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-bac-16s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-bac-23s-id98.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-bac-23s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-arc-16s-id95.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-arc-16s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-arc-23s-id98.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-arc-23s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-euk-18s-id95.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-euk-18s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/silva-euk-28s-id98.fasta,/opt/01_Assembly/sortmerna-2.1b/index/silva-euk-28s:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/rfam-5s-database-id98.fasta,/opt/01_Assembly/sortmerna-2.1b/index/rfam-5s-db:/opt/01_Assembly/sortmerna-2.1b/rRNA_databases/rfam-5.8s-database-id98.fasta,/opt/01_Assembly/sortmerna-2.1b/index/rfam-5.8s-db --reads 01_RawData/*_merge.fastq --num_alignments 1 --sam --fastx --aligned 02_Clean_RawData/OUTPUT_FILE_rRNA --other 02_Clean_RawData/OUTPUT_FILE_non_rRNA --log -a 8 -v

echo -e "Cleaning - remove repeated reads\n"
cd-hit -i 02_Clean_RawData/*_non_rRNA.fastq -o 02_Clean_RawData/OUTPUT_FILE_cd_hit.fastq -c 1.0 -n 5 -M 16000 -d 0 -T 8

echo -e "Cleaning - remove reads with N, run fastqc and paired reads\n"
/opt/01_Assembly/sortmerna-2.1b/scripts/unmerge-paired-reads.sh 02_Clean_RawData/*_cd_hit.fastq 02_Clean_RawData/OUTPUT_FILE_R1.fq 02_Clean_RawData/OUTPUT_FILE_R2.fq
trim_galore --paired 02_Clean_RawData/*.fq --max_n 1 --length 75 --retain_unpaired --fastqc -o ./02_Clean_RawData

echo -e "Assembler De Novo - IDBA-UD and BlastX\n"
fq2fa --filter --merge 02_Clean_RawData/*_val_*.fq 02_Clean_RawData/OUTPUT_FILE.fasta
idba_ud -o 03_Assembler_idba_ud -r 02_Clean_RawData/*.fasta --pre_correction
diamond blastx -d /opt/01_Assembly/diamond-master/db/viruses/viruses_refseq.dmnd -q 03_Assembler_idba_ud/contig.fa -o 03_Assembler_idba_ud/01_OUTPUT_FILE_idba_blastout -f 100 --salltitles -k 1

echo -e "Assembler De Novo - SPAdes and BlastX\n"
python2 /opt/01_Assembly/SPAdes-3.11.0/bin/spades.py -t 8 --meta -k 21,33,55,77 -1 02_Clean_RawData/*_val_1.fq -2 02_Clean_RawData/*_val_2.fq -o 04_Assembler_spades
diamond blastx -d /opt/01_Assembly/diamond-master/db/viruses/viruses_refseq.dmnd -q 04_Assembler_spades/contigs.fasta -o 04_Assembler_spades/01_OUTPUT_FILE_spades_blastout -f 100 --salltitles -k 1

echo -e "Complete Analysis"
