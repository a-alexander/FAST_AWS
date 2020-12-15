project_name="fast_aws"
root_dir="/Users/adamalexander/Documents/$project_name"
lib_dir="$root_dir/libs"
pip install -r "$root_dir/api/requirements.txt" -t libs --upgrade
cd $lib_dir && zip -r9 "$root_dir/$project_name.zip" . \
&& cd "$root_dir/api" && zip -g ../"$project_name.zip" -r .

bucket_name="asa-lambdas"
cd $root_dir
aws s3 cp "$project_name.zip" s3://$bucket_name/"$project_name.zip"
echo "Upload complete!"