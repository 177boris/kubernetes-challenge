APP_NAME = k8s-resume-challenge
APP_VERSION = 1.0.0

AWS_ECR_ACCOUNT_ID = 533267165479
AWS_ECR_REGION = eu-west-2
AWS_ECR_REPO = $(APP_NAME)
AWS_PROFILE = Lanre

TAG ?= $(APP_VERSION)


.PHONY : docker/build docker/push docker/run docker/test

docker/build :
	docker build -t $(APP_NAME):$(APP_VERSION) .


docker/push : docker/build
	aws ecr get-login-password --region $(AWS_ECR_REGION) --profile $(AWS_PROFILE) | docker login --username AWS --password-stdin $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com
	docker tag $(APP_NAME):$(APP_VERSION) $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO)
	docker push $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO)
	
docker/run :
	docker run -p 80:8080 $(AWS_ECR_ACCOUNT_ID).dkr.ecr.$(AWS_ECR_REGION).amazonaws.com/$(AWS_ECR_REPO)

docker/test :
	#curl -XPOST 'http://localhost:9000/2015-03-31/functions/function/invocations' -d '{}'
	curl -Method POST "http://localhost:9000/2015-03-31/functions/function/invocations" -Body '{}'