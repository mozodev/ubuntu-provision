# https://manual.seatable.io/docker/Developer-Edition/Deploy%20SeaTable-DE%20with%20Docker/

mkdir -p /opt/seatable
chown -R vagrant:vagrant /opt/seatable
cp /vagrant/docker-compose.yml /opt/seatable/

# cd /opt/seatable && docker-compose up -d
# Start SeaTable service.
# docker exec -d seatable /shared/seatable/scripts/seatable.sh start

# Create an admin account.
# docker exec -it seatable /shared/seatable/scripts/seatable.sh superuser
