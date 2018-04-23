FROM elasticsearch:2

RUN apt-get update && apt-get install attr && setfattr -n user.pax.flags -v "em" /docker-java-home/jre/bin/java
