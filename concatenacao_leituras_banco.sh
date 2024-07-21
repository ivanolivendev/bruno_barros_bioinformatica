#!/bin/bash

# Diretório contendo os arquivos FASTA
input_dir="/home/codesfrom_ivan/analises_bruno/sortmerna/data"

# Arquivo de saída concatenado
output_file="/home/codesfrom_ivan/analises_bruno/sortmerna/merged_fasta.fasta"

# Concatenar todos os arquivos .fasta no diretório de entrada
cat ${input_dir}/*.fasta > ${output_file}

echo "Arquivos FASTA concatenados em ${output_file}"
