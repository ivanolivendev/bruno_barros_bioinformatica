from Bio import SeqIO
from Bio.Blast import NCBIWWW
from Bio.Blast import NCBIXML
import re

def split_sequence(sequence, max_length=1000000):
    """Divide a sequência em partes menores, cada uma com no máximo `max_length` bases."""
    return [sequence[i:i + max_length] for i in range(0, len(sequence), max_length)]

def perform_blast(query_sequence, db="nt"):
    """Executa o BLAST para uma sequência e retorna o resultado."""
    result_handle = NCBIWWW.qblast("blastn", db, query_sequence)
    return result_handle

def main():
    # Carregar a sequência do arquivo FASTA
    fasta_file = "/home/codesfrom_ivan/analies/bruno_barros_bioinformatica/amostras/contig.fa"
    sequences = SeqIO.parse(fasta_file, "fasta")
    
    for seq_record in sequences:
        sequence = str(seq_record.seq)
        print(f"Processando sequência {seq_record.id} com comprimento {len(sequence)} bases")

        # Dividir a sequência se for maior que o limite permitido
        split_sequences = split_sequence(sequence)
        
        for i, part in enumerate(split_sequences):
            print(f"Executando BLAST para parte {i + 1}/{len(split_sequences)}")
            result_handle = perform_blast(part)
            
            # Salvar o resultado em um arquivo XML
            result_filename = f"{seq_record.id}_part_{i + 1}_results.xml"
            with open(result_filename, "w") as out_file:
                out_file.write(result_handle.read())
            
            print(f"Resultados salvos em {result_filename}")

if __name__ == "__main__":
    main()

