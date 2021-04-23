#Fast API into Lambda. Terraform Deploy.

---

1. Fast API for the new hotness
2. Magnum for wrapping it into a Lambda
3. Quick bash (build.bash) script to bundle the API to a zip and uplaod to S3
4. Terraform for deploying that Lambda to AWS and piping it to API Gateway

---

## To Deploy:
1. After cloning do a:
   ```
   terraform init 
   ```
   from the terraform folder. 
2. Change the project name variable to suit.
3. You may need to change the policy naming (if it warns you to)
4. run the build.bash script which bundles everything up into a .zip which it then pushes to lambda after runing a 
terraform apply to apply the changes.
   
5. End up with the URL of your shiny new deployment.


<i>This uses the AWS cli (which you need to be logged in for) as well as Terraform. Both required locally.</i>

####Note to Self. 
Resist the urge to have Terraform create and upload the lambda zip file. It's easily possible but potentially too
 easy to shoot yourself in the foot, deploying in half state. This wouldbe further compounded using this is 
 a team.

####Credit
Heavily cribbed from this excellent article (part 1) for the FastAPI/magnum parts. 
https://towardsdatascience.com/fastapi-aws-secure-api-part-2-1123bff28b55