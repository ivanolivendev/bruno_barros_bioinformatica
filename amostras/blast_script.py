from Bio.Blast import NCBIWWW

# Caminho para o seu arquivo de sequência
input_file = "/home/codesfrom_ivan/analies/bruno_barros_bioinformatica/amostras/contig.fa"

# Ler a sequência do arquivo
with open(input_file, "r") as file:
    sequence = file.read()

# Realizar a busca BLAST
result_handle = NCBIWWW.qblast("blastn", "nt", sequence)

# Salvar o resultado em um arquivo
with open("blast_results.xml", "w") as out_handle:
    out_handle.write(result_handle.read())

print("BLAST search completed. Results saved to 'blast_results.xml'.")
