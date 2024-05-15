## Thoughts 

- Setting up Docker image for web app was pretty straightforward thanks to previous exp. 

- Choosing AWS EKS was a no-brainer as this is the cloud platform I am most familiar with. Also helped that I had an example EKS config in terraform handy. 


## Resources 

- The Kubernetes Book - Nigel Poulton 
- [EKS Reference Architecture - Clowdhaus](https://github.com/clowdhaus/eks-reference-architecture/tree/main)
- [EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- 


### Step 1 

- The CKAD is a work in progress and I prefer getting hands on while studying for cert exams so this works out well for me. 

### Step 2 

- I created the PHP docker image and tested it on my localhost. 

- Created a makefile to automate building and pushing the docker image. I knew I would probably have to do this several times so I decided to create a script to prevent having to do this manually. LAzy? maybe...


### Step 3 

- Encountered CrashLoopBackOff issue with pods in website-deployment