project_name="lambda_build"
root_dir="$PWD"
lib_dir="$root_dir/libs"

pip install -r "$root_dir/api/requirements.txt" -t libs --upgrade
cd $lib_dir && zip -r9 "$root_dir/terraform/$project_name.zip" . \
&& cd "$root_dir/api" && zip -g ../terraform/"$project_name.zip" -r .
#
#bucket_name="asa-lambdas"
#cd $root_dir
#echo Add version number. Format x.x
#read version_num
#aws s3 cp "$project_name.zip" s3://$bucket_name/"$project_name"/v"$version_num".zip
#echo "Upload complete!"