process INFILE_HANDLING {

    publishDir "${params.process_log_dir}",
        mode: "${params.publish_dir_mode}",
        pattern: ".command.*",
        saveAs: { filename -> "${task.process}${filename}" }

    container "ubuntu:focal"

    input:
        path input
        path query

    output:
        path "assemblies", emit: asm
        path "assemblies/*"
        path ".command.out"
        path ".command.err"
        path "versions.yml", emit: versions
        
    shell:
        '''
        source bash_functions.sh
        
        # Get input data
        shopt -s nullglob
        compressed_asm=( "!{input}"/*.{fa,fas,fsa,fna,fasta,gb,gbk,gbf,gbff}.gz )
        plaintext_asm=( "!{input}"/*.{fa,fas,fsa,fna,fasta,gb,gbk,gbf,gbff} )
        shopt -u nullglob
        msg "INFO: ${#compressed_asm[@]} compressed assemblies found"
        msg "INFO: ${#plaintext_asm[@]} plain text assemblies found"

        # Check if total inputs are > 2
        if [[ -f !{query} ]]; then
            total_inputs=$(( ${#compressed_asm[@]} + ${#plaintext_asm[@]} + 1 ))
        else
            total_inputs=$(( ${#compressed_asm[@]} + ${#plaintext_asm[@]} ))
        fi

        if [[ ${total_inputs} -lt 2 ]]; then
            msg 'ERROR: at least 2 genomes are required for batch analysis' >&2
        exit 1
        fi

        # Make tmp directory and move files to assemblies dir
        mkdir assemblies
        for file in "${compressed_asm[@]}" "${plaintext_asm[@]}"; do
            cp ${file} assemblies
        done

        # Decompress files
        if [[ ${#compressed_asm[@]} -ge 1 ]]; then
            gunzip ./assemblies/*.gz
        fi

        # Get all assembly files after gunzip
        shopt -s nullglob
        ASM=( ./assemblies/*.{fa,fas,fsa,fna,fasta,gb,gbk,gbf,gbff} )
        shopt -u nullglob
        msg "INFO: ${#ASM[@]} assemblies found after gunzip (if needed)"

        # Filter out and report unusually small genomes
        FNA=()
        for A in "${ASM[@]}"; do
        # TO-DO: file content corruption and format validation tests
            if [[ $(find -L "$A" -type f -size +45k 2>/dev/null) ]]; then
                FNA+=("$A")
            else
                msg "INFO: $A not >45 kB so it was not included in the analysis" >&2
            fi
        done

        if [ ${#FNA[@]} -lt 2 ]; then
            msg 'ERROR: found <2 genome files >45 kB' >&2
        exit 1
        fi

        # Check file size of query input
        if [[ -f !{query} ]]; then
            verify_file_minimum_size "!{query}" 'query' '45k'
        fi

        cat <<-END_VERSIONS > versions.yml
        "!{task.process}":
            ubuntu: $(awk -F ' ' '{print $2,$3}' /etc/issue | tr -d '\\n')
        END_VERSIONS
        '''
}
