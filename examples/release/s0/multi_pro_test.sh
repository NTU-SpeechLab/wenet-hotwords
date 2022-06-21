#!/bin/bash

. path.sh
export GLOG_logtostderr=1
export GLOG_v=2


test_data=ntu-conversation

wav_path_dir=data/$test_data
nj=4
cmd=run.pl
data=/datadrive/wenet/wenet-hotwords/examples/release/s0/$wav_path_dir

utils/split_data.sh --per-utt $data $nj
sdata=$data/split${nj}utt

utils/run.pl JOB=1:$nj $sdata/result.JOB.log  ./hotwords_test_wavlist.sh --file  $sdata/JOB
wait

:> ./conbined_text
for i in $(seq $nj) ;do
cat $data/split${nj}utt/$i/temp >> ./conbined_text
done

cp ./conbined_text ./conbined_text2
cat conbined_text2 | sort | sed 's#<context># #g' |sed 's#</context># #g'  > ./conbined_text

mv $wav_path_dir/text $wav_path_dir/text2
cat $wav_path_dir/text2 | sort  > $wav_path_dir/text

python tools/compute-wer.py --char=1 --v=1     $wav_path_dir/text ./conbined_text  > ./wer

cp wer $data/wer
cp conbined_text $data/decode_result
cat $data/wer | tail

