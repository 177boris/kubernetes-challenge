## Thoughts 

- Setting up Docker image for web app was pretty straightforward thanks to previous exp. 

- Choosing AWS EKS was a no-brainer as this is the cloud platform I am most familiar with. Also helped that I had an example EKS config in terraform handy. 

- Seemingly unfixable CrashLoopBackoff error when deploying pods on EKS initially, the docker image was built on arm64 infra on my local machine and the EKS nodes require images built for amd64...took a minute to figure that out.  


## Resources 

- The Kubernetes Book - Nigel Poulton 
- [EKS Reference Architecture - Clowdhaus](https://github.com/clowdhaus/eks-reference-architecture/tree/main)
- [EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [CrashLoopBackoff Error](https://spacelift.io/blog/crashloopbackoff)


### Step 1 - CKAD Cert

- The CKAD is a work in progress and I prefer getting hands on while studying for cert exams so this works out well for me. 

### Step 2 - Containerize Your E-Commerce Website and Database

- I created the PHP docker image and tested it on my localhost. 

- Created a makefile to automate building and pushing the docker image. I knew I would probably have to do this several times so I decided to create a script to prevent having to do this manually. LAzy? maybe...


### Step 3 - Set Up Kubernetes on AWS (a Public Cloud Provider)

- I've been able to deploy a Terraform EKS config with managed nodes. Potentially trying Fargate/Serverless down the line. I just feel using managed nodes first helps get a better understanding of how everything works. 

### Step 4 - Deploy Your Website to Kubernetes

- Encountered CrashLoopBackOff issue with pods in website-deployment, root cause was the build platform being used on my local to create the PHP docker image. I fixed this by running the docker command with the platform flag like so 

`docker build --platform="linux/amd64" -t $(APP_NAME):$(APP_VERSION) .`

- After a few hours of looking for typos/misconfigurations I was happy/angry this was the issue. 

- All pods running now...


### Step 5 - Expose Your Website

- Figured out using ConfigMaps and Secrets to pass env variables to both DB and Web app. 

- Created services for both mariadb and web app pretty quickly. Tested the app on my browser and the load balancer URL directs me to the web app. Initially, I thought there were issues but my browser tried to access the URL using HTTPS instead of HTTP, obvs wasn't going to work yet...


### Step 6 - Implement Configuration Management

- Already using ConfigMaps to pass DB creds to web app and mariadb pods. 

- Creating a ConfigMap for the feature-toggle-config was straightforward. 


### Step 7 - Scale Your Application

- Kubectl scale command was easy to understand, can also edit the deployment to increase number of replicas which is more common. 

` kubectl scale deployment/ecom-web --replicas=6 `

- Also did some load testing using the hey cli tool to simulate web traffic to the website.

![Load testing](./Images/load-test1.png)


### Step 8 - Perform a Rolling Update

- Updated the index.php to include code for enabling/disabling dark mode so I rebuilt the php container and implemented the rolling update easily.  


### Step 9 - Roll Back a Deployment

- Easy to understand and implement rollbacks.

### Step 10 -