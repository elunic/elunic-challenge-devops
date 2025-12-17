resource "null_resource" "task3_pod" {
  connection {
    type        = "ssh"
    user        = var.ssh_username
    private_key = file(var.ssh_private_key_path)
    host        = var.ssh_host
    port        = var.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
kubectl apply -f - --context kind-elunic-challenge <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: http-client
  namespace: default
  labels:
    role: http-client
spec:
  containers:
  - name: curl
    image: curlimages/curl:latest
    command: ["/bin/sh"]
    args: ["-c", "sleep 3600"]
EOF
EOT
    ]
  }
}

resource "null_resource" "task3_networkpolicy" {
  depends_on = [null_resource.task3_pod]

  connection {
    type        = "ssh"
    user        = var.ssh_username
    private_key = file(var.ssh_private_key_path)
    host        = var.ssh_host
    port        = var.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
kubectl apply -f - --context kind-elunic-challenge <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-http-client
  namespace: t3
spec:
  podSelector:
    matchLabels:
      app: task-3
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
            kubernetes.io/metadata.name: default
      podSelector:
        matchLabels:
          role: http-client
    ports:
    - protocol: TCP
      port: 80
EOF
EOT
    ]
  }
}