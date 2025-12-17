resource "null_resource" "task4_namespace" {
  connection {
    type        = "ssh"
    user        = var.ssh_username
    private_key = file(var.ssh_private_key_path)
    host        = var.ssh_host
    port        = var.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl create namespace t4 --context kind-elunic-challenge || true"
    ]
  }
}

resource "null_resource" "task4_echochamber" {
  depends_on = [null_resource.task4_namespace]

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
  name: echochamber
  namespace: t4
spec:
  containers:
  - name: echochamber
    image: gini/echochamber:latest
    securityContext:
      privileged: true
EOF
EOT
    ]
  }
}