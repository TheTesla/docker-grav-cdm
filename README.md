# Grav CMS in Docker container

Create this volume first:

```bash
sudo docker volume create --driver local --opt type=none --opt device=/home/stefan/projects/docker-grav-cdm/testvol --opt o=bind testvol
```

It will contain all the user created content including theuser accounts of grav. It must be created manualy with the command above. This enables docker to copy the prefilled subdirectory inside the container to the external volume. Implicitely created docker volumes will suppress the internal data.

Now build and run the container:

```bash
sudo docker build . --tag gravtest:0.1
sudo docker run --publish 80:80 -v testvol:/var/www/html/user/ --name gravcontainer gravtest:0.1
```

Now enjoy Grav on http://localhost/

