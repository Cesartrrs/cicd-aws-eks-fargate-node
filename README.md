# CI/CD AWS ECS Fargate – RECETA PASO A PASO

(para ejecutar de principio a fin)

PRECONDICIONES (ANTES DE EMPEZAR)

Tener cuenta de AWS
Tener cuenta de GitHub
Tener Docker instalado
Tener Terraform instalado
Tener AWS CLI instalado
Tener en GitHub > Settings > Secrets:

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

## PASO 1 – BOOTSTRAP DE TERRAFORM (SE EJECUTA UNA SOLA VEZ)

Objetivo: crear backend remoto de Terraform (S3 + DynamoDB)

Ir a la carpeta bootstrap:

cd infra/terraform/bootstrap
Inicializar Terraform:
terraform init

Crear recursos de backend:
terraform apply

Confirmar en AWS:
Existe un bucket S3 para terraform state
Existe una tabla DynamoDB para locking

NO volver a ejecutar este paso.

## PASO 2 – CREAR INFRAESTRUCTURA PRINCIPAL

Objetivo: crear VPC, ALB, ECS Fargate, Service

Ir a la carpeta del entorno:
cd infra/terraform/envs/dev
Inicializar Terraform con backend remoto:
terraform init

Crear infraestructura:
terraform apply

Guardar el output que aparece:
alb_dns_name = URL
Abrir en navegador:
http:// URL
Confirmar que la aplicación responde.

## PASO 3 – CI (BUILD Y PUSH DE IMAGEN DOCKER)

Objetivo: construir imagen y subirla a ECR

Archivo involucrado:
.github/workflows/ci.yml

Acción a ejecutar:
git push

Resultado esperado:
Imagen Docker construida
Imagen subida a ECR

Tags creados:
latest
sha-commit

NO se despliega nada en este paso.

## PASO 4 – CD (DEPLOY A ECS)

Objetivo: desplegar una imagen específica en ECS

Archivo involucrado:
.github/workflows/deploy.yml

Acciones:
Ir a GitHub
Abrir el repositorio
Ir a Actions

Seleccionar workflow:
“CD - Deploy to ECS (Terraform)”
Click en “Run workflow”

En el campo image_tag escribir:
latest
o
sha-commit

Ejecutar workflow

Resultado esperado:
terraform apply ejecutado
Nueva Task Definition creada
ECS Service hace rollout automático

## PASO 5 – VERIFICAR DEPLOY

Ir a AWS Console:
ECS → Clusters → cluster → Services → Deployments

Confirmar:
Desired = 1
Running = 1

Deployment PRIMARY activo
Abrir nuevamente en navegador:
http://<ALB_URL>

## PASO 6 – DESTROY (APAGAR TODO)

Objetivo: eliminar toda la infraestructura y dejar costos ~0

Archivo involucrado:
.github/workflows/destroy.yml

Acciones:
Ir a GitHub
Ir a Actions

Seleccionar workflow:
“CD - Destroy (Terraform)”
Click en “Run workflow”

En el campo confirm escribir EXACTAMENTE:
DESTROY

Ejecutar workflow

Resultado esperado:
ECS eliminado
ALB eliminado
Security Groups eliminados
Red eliminada
Backend de Terraform (S3 + DynamoDB) NO se elimina

FLUJO COMPLETO (RESUMEN)

bootstrap
→ terraform apply
→ git push
→ CI (build & push image)
→ CD (terraform apply)
→ ECS + ALB
→ destroy

NOTAS IMPORTANTES

CI puede ejecutarse aunque no exista infraestructura
CD y Destroy usan Terraform
Destroy no afecta CI
La infraestructura puede recrearse repitiendo el PASO 2

Para despliegues reproducibles usar siempre sha-commit
