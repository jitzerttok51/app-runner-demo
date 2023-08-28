### GitHub IPs
curl \
-H "Accept: application/vnd.github.v3+json" \
https://api.github.com/meta | jq .actions


terraform apply -target=data.aws_ecr_authorization_token.token -auto-approve
terraform output -raw ecr-password
terraform output -raw app-repository-path
gradlew -Pecr.image.name=${{ steps.tf.outputs.ecr-path  }} -Pecr.token=${{ steps.tf.outputs.ecr-token }} -Pbuild.number=${{ github.run_number }} bootBuildImage