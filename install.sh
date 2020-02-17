#/bin/bash
# export AWS_ACCOUNT_ID=$(aws sts get-caller-identity|jq '.["Account"]'|read h;echo ${h:1:-1})
export AWS_ACCOUNT_ID_ROW=$(aws sts get-caller-identity|jq '.["Account"]')
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID_ROW:1:${#AWS_ACCOUNT_ID_ROW}-2}
git clone https://github.com/ispec-inc/kube-go-template.git
read -p "application name?: " app_name
read -p "use dev? (y/N): " yn
case "$yn" in
    [yY]*) use_dev=true ;;
    *) use_dev=false ;;
esac

read -p "use stg? (y/N): " yn
case "$yn" in
    [yY]*) use_dev=true ;;
    *) use_dev=false ;;
esac

declare -a envs=("prod")

if $use_dev;then
envs+=("dev")
fi

if $use_stg;then
envs+=("stg")
fi

cp kube-go-template/container/Dockerfile Dockerfile
cp kube-go-template/container/docker-compose.yml docker-compose.yml

if [ ! -e .github/workflows ];then
  mkdir -p .github/workflows
fi
cp kube-go-template/workflow.yml ./.github/workflows/prod.yml

sed -i "" -e "s/{{app_name}}/$app_name/" docker-compose.yml

for env in ${envs[@]}
do
  if [ ! -e k8s/${env} ]; then
    mkdir -p k8s/${env}
  fi
  cp kube-go-template/manifest/* k8s/"${env}"
  find k8s/"${env}"/*.yml | xargs sed -i "" -e "s/{{app_name}}/$app_name/"
  find k8s/"${env}"/*.yml | xargs sed -i "" -e "s/{{aws_account_id}}/$AWS_ACCOUNT_ID/"
done

find .github/workflows/prod.yml | xargs sed -i "" -e "s/{{app_name}}/$app_name/"
rm -rf kube-go-template
