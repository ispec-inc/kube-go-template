#/bin/bash
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

if [ ! -d  ".github/workflows"];then
  mkdir -p .github/workflows
fi
cp workflow.yml .github/workflows/prod.yml

sed -i "" -e "s/{{app_name}}/$app_name/" docker-compose.yml
mkdir k8s
for env in ${envs[@]}
do
mkdir k8s/${env}
cp kube-go-template/manifest/* k8s/"${env}"
find k8s/"${env}"/*.yml | xargs sed -i "" -e "s/{{app_name}}/$app_name/"
find workflow.yml | xargs sed -i "" -e "s/{{app_name}}/$app_name/"
done
rm -rf kube-go-template
