# Configuración de permisos con la  API_KEY para el aprovisionamiento de recursos
provider "ibm" {
  ibmcloud_api_key    = "${var.ibmcloud_api_key}"

}

