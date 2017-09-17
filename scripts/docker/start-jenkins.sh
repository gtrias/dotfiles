sudo docker run -d --name jenkins --add-host gitlab.caprica.cir:`/sbin/ip route|awk '/default/ { print  $3}'` -p 8080:8080 -v /var/www/.ssh:/root/.ssh -v /home/cirici/jenkins:/var/lib/jenkins gtrias/jenkins sh run_all.sh

