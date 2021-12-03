# generate the diff day files that indicate which days need to be processed 
module load anaconda3/2019.10
source activate urseismo
output_root_path="/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/2_Data/preprocessed_data"
input_root_path="/scratch/tolugboj_lab/Prj10_DeepLrningEq/9_DanielSequencer/3_src/obspy_batch"
diff_day_path="/scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_prepross/diff_day"

cd /scratch/tolugboj_lab/Prj5_HarnomicRFTraces/para_prepross/
#python3 ./generate_diff.py $input_root_path $output_root_path $diff_day_path

# calling stations parallely to pre-process
for file in ${diff_day_path}/*
do
	filename=$(basename "$file")
	netsta=$(echo $filename | cut -d'.' -f 1)
	net=$(echo $netsta | cut -d'-' -f 1)
	sta=$(echo $netsta | cut -d'-' -f 2)
	rawdata="${input_root_path}/${net}/${net}-${sta}/datarepo/data/${net}/"

	sbatch --job-name=$net.$sta.run --output=$net.$sta.out --export=net=$net,sta=$sta,netdir=$rawdata,outroot=$output_root_path,dayfile=$file pre_pross.slurm 
done
