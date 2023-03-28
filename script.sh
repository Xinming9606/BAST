~/RibDif/RibDif.sh -g Bacillus
# download Bacillus genomes via RibDif


ncbi-genome-download  -F 'cds-fasta' -l 'complete' --genera Bacillus bacteria --flat-output -o ~/Bacillus -p 2
# or download all cds.fasta files of Bacillus group


gzip -d *.gz
# to decompress all cds.fasta files in your folder


rename -v 's/_cds_from_genomic//' *.fna
rename -v 's/ASM//' *.fna
rename -v 's/GCF_0/GCF_/' *.fna
# rename all the fna files to avoid error in prokka


for file in *.fna; do tag=${file%.fna}; prokka --kingdom Bacteria --outdir ~/Bacillus/"$tag" --genus Bacillus --locustag "$tag" --compliant --force --centre XXX ~/Bacillus/"$file"; done
# bulk annotation


for folder in ~/Bacillus/GCF*; do
    for obj in $(ls $folder); do
        echo ${folder##*/}
        mv -v $folder/$obj $folder/${folder##*/}.${obj##*.}
    done
done
# classify different format files 


mkdir gff_files
cp ./*/*.gff gff_files
# gff files for roary


mkdir ffn_files
cp ./*/*.ffn ffn_files
# ffn files for extracting candidate gene sequences


for file in ~/ffn_files/*.ffn; do
    cat $file | rg --multiline ">.*DNA-directed RNA polymerase subunit beta[ATCG\n]*" >> rpoB.txt
done
# extract rpoB sequences


roary -f ./demo -e -n -v -p 8 ~/gff_files/*.gff
# pan-genome analysis for Bacillus genus


wget http://www.ormbunkar.se/aliview/downloads/linux/linux-version-1.28/aliview.tgz
tar xzf aliview.tgz
cd ~/aliview
./aliview
# view sequence alignment


vsearch -cluster_fast ~/rpoB.fasta -strand both --id 1 --uc ~/cluster_rpoB.fasta --centroids centroid_seq_rpoB.fasta --clusterout_id --consout rpoB_cluster.txt
# dereplicate sequences


curl https://raw.githubusercontent.com/egonozer/in_silico_pcr/master/in_silico_PCR.pl -o in_silico_PCR.pl
perl in_silico_PCR.pl
# in silico PCR


muscle -in rpoB_amplicons.fasta -out rpoB_align.fasta
# align sequences


FastTree rpoB.fasta > rpoB.tree
# build phylogenetic tree


TreeCluster.py -i rpoB.tree -o rpoB_cluster.tree -t 0.045
# TreeCluster


makeblastdb -in ~/Syn_Com_seq/phyloseq/tuf2_dataset.fasta -dbtype nucl -out Elongation_factor_Tu2
# make blast database

blastn -query ~/Syn_Com_seq/phyloseq/rep-seqs.fasta -out blast_result.txt -db Elongation_factor_Tu2 -outfmt 10 -max_target_seq 1
# command line blast tool to assign taxonomy to representative sequences of amplicon data
# '10 qaccver saccver pident'
# choose database, outformat, only show query acc.ver, subject acc.ver, % identity and the top hit.