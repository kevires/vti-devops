kubectl create namespace hello

kubectl run app-hello --image nginx -n hello
